defmodule ListenList.Email do
  defdelegate subscribe_confirmation(subscriber, confirm_token),
    to: ListenList.Email.SubscribeConfirmation,
    as: :create

  defdelegate weekly_releases(subscribers, releases),
    to: ListenList.Email.WeeklyReleases,
    as: :create
end
