# from _navigation_home_html.heex:

```
 <button class="btn-nav xs:place-self-center"><%= link("My Little Thinkers", to: Routes.little_thinker_path(@conn, :index)) %></button>
    <%= if @current_user.role in ["The Little Thinker"] do %>
      <button class="btn-nav xs:place-self-center"><%= link("Ulrik's crew", to: Routes.crew_path(@conn, :index)) %></button>
    <% else %>
    <% end %>
```