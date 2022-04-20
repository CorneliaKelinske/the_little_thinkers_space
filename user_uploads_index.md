# User uploads index

Read up on nested resources

https://hexdocs.pm/phoenix/routing.html#nested-resources

We want something like 

resources "/little_thinkers", LittleThinkerController do
  resources "/uploads", UploadController
end

- [ ] Create the routes
- [ ] Modify the controllers and actions as needed
- [ ] Make sure that only authorized people can access the uploads
- [ ] Make sure that only the little thinker can alter uploads


# Order uploads

https://hexdocs.pm/ecto/Ecto.Query.html#order_by/3

- [ ] Order uploads in reverse chronological order