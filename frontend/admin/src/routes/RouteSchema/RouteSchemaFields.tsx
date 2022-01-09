import { computed, defineComponent, ref, toRaw, watchEffect } from "vue";
import { faPlus, faTimes } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@potionapps/utils";
import { Field, FieldUpdateInput, RootMutationType } from "shared/types";
import { useMutation } from "@urql/vue";
import { useRoute } from "vue-router";
import BtnSmallBordered from "components/Btn/BtnSmallBordered";
import Draggable from "vuedraggable/src/vuedraggable";
import Title from "components/Title/Title";
import fieldCollection from "shared/models/Schemas/Field/fieldCollection.gql";
import fieldOrderingMutation from "shared/models/Schemas/Field/fieldOrderingMutation.gql";
import useQueryTyped from "hooks/useQueryTyped";
import SchemaFieldRow from "components/SchemaFieldRow/SchemaFieldRow";

export default defineComponent({
  name: "RouteSchemaFields",
  setup() {
    const draggableState = ref<Field[]>([]);
    const route = useRoute();
    let toSave: FieldUpdateInput[] = [];
    const isSaving = ref(false)
    let saveTimeout = 0
    const { executeMutation } = useMutation(fieldOrderingMutation)

    const { data } = useQueryTyped({
      query: fieldCollection,
      variables: computed(() => {
        return {
          first: 200,
          filters: {
            schemaId: route.params.id,
          },
        };
      }),
    });

    const fields = computed(() => {
      return data.value?.fieldCollection?.edges?.reduce(
        (acc: Field[], edge) => acc.concat(edge?.node ? [edge.node] : []),
        []
      );
    });

    const onChange = (res: {
      moved: { element: Field; newIndex: number; oldIndex: number };
    }) => {
      toSave = draggableState.value.reduce((acc: FieldUpdateInput[], el, i) => {
        if (
          i !==
          fields.value?.find((node) => node?.id === el.id)?.ordering
        ) {
          acc.push({
            id: el.id,
            ordering: i,
          });
        }
        return acc;
      }, []);
      window.clearTimeout(saveTimeout)
      isSaving.value = true
      window.setTimeout(() => { 
        isSaving.value = false
        save(toSave)
      }, 1000)
    };

    const save = (fields: FieldUpdateInput[]) => {
      return executeMutation({ fields })
    }

    watchEffect(() => {
      if (
        fields.value &&
        fields.value?.length !== draggableState.value.length
      ) {
        draggableState.value = fields.value.map((k) => toRaw(k));
      }
    });

    return () => {
      return (
        <>
          <div class="flex items-center justify-between mb-3">
            <Title>Fields</Title>
            <BtnSmallBordered class="gap-3">
              New Field <FontAwesomeIcon icon={faPlus} />
            </BtnSmallBordered>
          </div>
          <Draggable
            class={[
              "border-slate-300",
              "border-1",
              "flex",
              "flex-col",
              "gap-1.5",
              "px-4",
              "py-6",
              "rounded-xl",
              "shadow-sm",
              "w-full",
            ]}
            itemKey="id"
            onChange={onChange}
            onInput={onChange}
            v-model={draggableState.value}
            v-slots={{
              item: ({ element: el }: { element: Field; index: number }) => {
                return (
                  <div class={[]} key={el!.id}>
                    <div class={["flex", "relative", "w-full"]}>
                      <div
                        class={[
                          "absolute",
                          "bg-gray-200",
                          "cursor-pointer",
                          "flex",
                          "hover:bg-gray-800",
                          "hover:text-white",
                          "h-7",
                          "items-center",
                          "justify-center",
                          "-right-2",
                          "rounded-full",
                          "shadow-xl",
                          "text-gray-600",
                          "transition",
                          "-top-2",
                          "w-7",
                          "z-3",
                        ]}
                        // onClick={() => remove(pp)}
                      >
                        <FontAwesomeIcon class="text-sm" icon={faTimes} />
                      </div>
                      <SchemaFieldRow title={el!.titleI18n} />
                    </div>
                  </div>
                );
              },
            }}
          />
        </>
      );
    };
  },
});
