<p id="notice"><%= notice %></p>

<p>
  <strong>Person:</strong>
  <%= @reservation.person.full_name %>
</p>

<p>
  <strong>Event:</strong>
  <%= @reservation.event.title %>
  </br>
  <%= @reservation.event.description %>
</p>

<p>
  <strong>Status:</strong>
  <%= @reservation.aasm_state %>
</p>

<p>
  <strong>Created by:</strong>
  <%= @reservation.user.name %>
</p>

<p>
  <strong>Attended at:</strong>
  <%= @reservation.attended_at %>
</p>

<%= link_to 'Back', v2_reservations_path %>
