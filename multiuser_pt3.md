# Where we at now

- We have changed user roles to "Little Thinker", "Admin", and "Crew"
- Users are linked to the (currently one) LT in the relationships table
- In addition to the LT_id and user_id of the "follower", the relationship table also specifies the type of relationship the user has to the LT
- There is an associated relationships schema, which also includes a type validation
- valid types are "Parent", "Family", "Friend"
- Parent will have more rights than the other two
- I am differentiating between "Family" and "Friend" as there might be cases in which content is to be shared only within a family

# What now?!

## NOTE: I currently do not have an edit_user function. I think I need to have one, to make changes to existing users easier. For instance, family members are currently entered with wild first names such as Aunty Meaghan or Grandpa. Initially, I thought that an edit user function would not be necessary, but I am missing it now.

- [] add an edit user function
- [] add a crew controller
- [] switch the crew page over to a crew index page
- [] just show first and last name
- [] figure out how to add a show link to the user's profile if a user has one

- and then we need more logic


##### Tickets #####

# Add an edit user function 

We need an edit user function so that the Admin can easily edit users, for instance if there is a
typo in their names. This function cannot be used to edit their email address though, as the email address
is used to register a user. Also need to check if there is any conflict with user registration

### Acceptance
- [ ] add an update_user function to accounts.ex
- [ ] add an edit action to the user controller
- [ ] add an edit_user template (potentially also a form template)
- [ ] add update_user test to the accounts test
- [ ] add edit user user test to the user_controller test

################################################################

# Relationship controller, routes, views, templates

We need a relationship controller to work with the relationships table and the connection between a little thinker and a crew.

- [ ] create a relationship view
- [ ] create relationship template folder with an index.heex
- [ ]

(initial authorization as before)