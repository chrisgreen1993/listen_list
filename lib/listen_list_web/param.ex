# Define how Phoenix should handle Dates in URLs
defimpl Phoenix.Param, for: Date do
  def to_param(date) do
    Date.to_string(date)
  end
end
