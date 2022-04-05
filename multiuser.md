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



- A crew can only view little thinkers that they are following on little_thinker_crew table
- A crew can only view uploads with a user_id for a little thinker that they follow
- A crew cannot upload files
- A little thinker can only see their own uploads and the uploads of people they are following
- A little thinker can upload files
- A little thinker can see which crew is following them
- A little thinker can follow others just like crew
- An admin does not need to follow anyone, and can access everything.

Roles
- Crew: Can follow people
- Little thinker: Can do everything that crew can do, plus upload content
- Admin: can do everything Little thinker can do, plus everything else





3. User creation
- as before, only with the last name added
- if chosen role is little thinker: as usual
- otherwise: another mask, where the user is connected to the little thinker, by entering the first and 
last name of the little thinker
- behind the scene, I make a query Select id from User where first name is given first name and last name is given last name, verify that that person is a little thinker
- make entry into the lt_crew table with that little thinker and the new user

TRICKY: following more than one lt

4. some kind of link where a user can sign up to follow another little thinker
BUT: there must be some kind of approval first

-- maybe another role? parent? admin is allowed to see everything and allowed everywhere in all spaces. but there 
probably should be a parent (pseudo admin) who has admin rights in the space of the lt --

request email is sent to admin
admin adds first and last name to crew

5. Design questions where does a person land? which space?

6. Login needs to be changed. It needs to be with first name, last name and password. right now there is a unique constraint in the user.ex file on email. however, parents might have multiple kids signed up


## Tickets

# ##########################

# Add last name to users

Currently we only have name for users which is their first name. We also need a last name and then we can enforce uniqueness across them.

There is a edge case of two identically named people signing up that we are going to ignore until it becomes a later problem.

### Acceptance
- [ ] Add last_name to users table
- [ ] Rename name to first_name on users table
- [ ] Add a unique index on [first_name, last_name]
- [ ] Add last name to forms
- [ ] Add last name to changeset attrs
- [ ] Require last name on changeset
- [ ] Add last name to module attribute test data
- [ ] Search and replace name to first name (and last name)

# ##########################

# Backfill and set last_name to null: false

We need to backfill the users table with last names

### Acceptance
- [ ] Backfill all last_names in the users table
- [ ] Set last_name to null: false

# #########################

#  Show followers to the little thinker under crew tab 

In the current one-thinker environment, the little thinker sees everybody else (who has a profile) under the crew tab.
In order to prepare for multiple thinkers and multiple crews, the crew is to show everybody who is linked to the lt in the
lt_crew join table. 

(if a person does not have a profile, their name will still be shown in the crew table but there won't be a show button)

### Acceptance
- [ ] Write function in acccounts.ex to retrieve the lt's crew from the repo
  (query for crew would be crew_id for users in ls_crew table where lt_id = the user_id of the current lt (here: 5))
- [ ] use the new way of retrieving the crew in the crew template
- [ ] check tests
- [ ] double-check authorization

# #########################