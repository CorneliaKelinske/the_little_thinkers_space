# Grooming

## Goals

We want a many to many relationship between little thinkers and their crew.

Little thinkers and their crew are all Users.

Create a new table called little_thinker_crew
  little_thinker_id: id
  crew_id: id
  
When a user wants to follow another user, create an entry in that table

Current roles:
["Admin", "The Little Thinker", "Family", "Friend"]