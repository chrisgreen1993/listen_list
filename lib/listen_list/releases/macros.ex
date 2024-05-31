defmodule ListenList.Releases.Macros do
  alias ListenList.Releases.Release

  # Macro to generate the ON CONFLICT clause for the release import
  # The update: parameter doesn't let us to build fragments dynamically,
  # so instead we use a macro do do it.
  # this generates fragments that update all fields except for import_status, artist and album
  # if import_status has a value of 'manual' or 'rejected' we keep the existing value
  defmacro create_or_update_conflict_action() do
    # We do not want to update the id or inserted_at fields
    fields = Release.__schema__(:fields) -- [:id, :inserted_at]

    set_list =
      Enum.map(fields, fn field ->
        case field do
          field when field in [:artist, :album, :import_status] ->
            # for these fields we generate an SQL case statement to check the existing value in import_status
            quote do
              {unquote(field),
               fragment(
                 "CASE WHEN ? IN ('manual', 'rejected') THEN ? ELSE excluded.? END",
                 field(r, :import_status),
                 field(r, ^unquote(field)),
                 literal(^Atom.to_string(unquote(field)))
               )}
            end

          _ ->
            # the rest of the fields we just update with the new value
            quote do
              {unquote(field), fragment("excluded.?", literal(^Atom.to_string(unquote(field))))}
            end
        end
      end)

    quote do
      from(r in Release, update: [set: unquote(set_list)])
    end
  end
end
