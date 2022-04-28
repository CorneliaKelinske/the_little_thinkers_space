# from _navigation_home_html.heex:

```
 <button class="btn-nav xs:place-self-center"><%= link("My Little Thinkers", to: Routes.little_thinker_path(@conn, :index)) %></button>
    <%= if @current_user.role in ["The Little Thinker"] do %>
      <button class="btn-nav xs:place-self-center"><%= link("Ulrik's crew", to: Routes.crew_path(@conn, :index)) %></button>
    <% else %>
    <% end %>
```

# from home.html.heex:

the buttons:

```
<div class="mt-4 mb-48 flex justify-center w-screen">
    <%= if @lt_profile_id == nil do %>
      <button class="btn-page"><%= link("Ulrik's profile", to: Routes.page_path(@conn, :home)) %></button>
    <% else %>
      <button class="btn-page"><%= link("Ulrik's profile", to: Routes.profile_path(@conn, :show, @lt_profile_id)) %></button>
    <% end %>
    <button class="btn-page"><%= link("Uploads", to: Routes.little_thinker_upload_path(@conn, :index, @little_thinker)) %></button>
  </div>
  ```