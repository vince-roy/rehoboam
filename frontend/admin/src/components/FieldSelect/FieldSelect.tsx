import { computed, defineComponent, onMounted } from "vue";
import { useField, useFieldSelect } from "@potionapps/forms";
import FieldError from "../FieldError/FieldError";
import FieldLabel from "../FieldLabel/FieldLabel";

export interface FieldSelectProps {
  default?: string
  name: string
  label?: string
  unstyled?: boolean
}

export default defineComponent({
  name: "FieldSelect",
  props: {
    disabled: Boolean,
    label: String,
    name: {
      required: true,
      type: String
    },
    unstyled: Boolean
  },
  setup (props, ctx) {
    const {
      change,
      errors,
      onBlur,
      showErrors,
      val
    } = useField({
      name: computed(() => props.name)
    })
    
    const {
      internalValue,
      onChange
    } = useFieldSelect({
      change,
      name: props.name,
      showErrors,
      val
    })

    const classes = computed(() => {
      const base = "block rounded-md shadow-sm focus:border-indigo-300 p-2 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 w-full "
      return base + (showErrors?.value ? "border-red-300 text-red-800" : "border-gray-300")
    })

    return () => <>
      {
        props.label &&
        <FieldLabel>{props.label}</FieldLabel>
      }
      <select
        class={classes.value}
        disabled={props.disabled}
        onBlur={onBlur}
        onChange={onChange}
        name={props.name}
        {...ctx.attrs}
        value={internalValue.value}
      >
        {ctx.slots.default && ctx.slots.default()}
      </select>
      {
        showErrors.value &&
        <FieldError>{errors.value.join(", ")}</FieldError>
      }
    </>
  }
})