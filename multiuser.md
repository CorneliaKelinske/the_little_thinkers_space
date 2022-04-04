# Grooming

## Goals

We want a many to many relationship between little thinkers and their crew.

Little thinkers and their crew are all Users.

Create a new table called little_thinker_crew
  little_thinker_id: id
  crew_id: id
  
  
  id | little_thinker_id | crew_id
  1  | 1                 | 3
  2  | 1                 | 5
  3  | 8                 | 1
  
  
  
When a user wants to follow another user, create an entry in that table

Current roles:
["Admin", "The Little Thinker", "Family", "Friend"]

## 1. Create migration

Create `little_thinker_crew_table`
Add little_thinker_id, id
Add crew_id, id
Make sure there is an index on both of them
Create a unique_index for [little_thinker_id, crew_id]
Create an index for crew_id

## 2. Figure out how to connect to fly.io database

Need to connect with datagrip, look up docs?

## 3. Backfill little_thinker_crew table.

Entries need to be inserted with SQL statements to represent all the people who are viewing uli's profile
Modify seeds to represent new table

## 4. Code Changes
https://hexdocs.pm/ecto/self-referencing-many-to-many.html
remove unique index on lt role


- A crew can only view little thinkers that they are following on little_thinker_crew table
- A crew can only view uploads with a user_id for a little thinker that they follow
- A crew cannot upload files
- A little thinker can upload files
- A little thinker can see which crew is following them
- A little thinker can follow others just like crew
- An admin does not need to follow anyone, and can access everything.

Roles
- Crew: Can follow people
- Little thinker: Can do everything that crew can do, plus upload content
- Admin: can do everything Little thinker can do, plus everything else