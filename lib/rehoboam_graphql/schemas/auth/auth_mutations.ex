defmodule RehoboamGraphQl.Schema.AuthMutations do
  use Absinthe.Schema.Notation

  object :auth_mutations do
    field :session_renew, type: :sign_in_provider_result do
      resolve(
        Potionx.Auth.Resolvers.resolve_renew(session_service: Rehoboam.Sessions.SessionService)
      )

      middleware(&Potionx.Auth.Resolvers.middleware_renew/2)
    end

    field :sign_out, type: :sign_in_provider_result do
      resolve(
        Potionx.Auth.Resolvers.resolve_sign_out(session_service: Rehoboam.Sessions.SessionService)
      )

      middleware(&Potionx.Auth.Resolvers.middleware_sign_out/2)
    end

    field :sign_in_provider, type: :sign_in_provider_result do
      arg(:provider, non_null(:string))
      arg(:redirect_url, :string)

      resolve(
        Potionx.Auth.Resolvers.resolve_sign_in(session_service: Rehoboam.Sessions.SessionService)
      )

      middleware(&Potionx.Auth.Resolvers.middleware_sign_in/2)
    end
  end
end
