I need to separate crew from users.

Users is everyone.
Crew is everyone connected to one particular little thinker.

I also need one extra role of "Parent".
"Parent" has the same rights as "Admin", however only in relation to their little thinker.

## How will it work in practice?

Users always need association with a little thinker.
Initial set of users (little thinker and a parent) can only be created by the Admin

Probably good idea to link little thinker to themselves in the join table as well. Might make authorization 
easier later on.
(backfill)

## Step by step

1. Admin is created (already is)

2. Admin creates a little thinker (joined to the little thinker in the join table)

3. Admin creates a parent who upon their creation is also linked to the little thinker

4. For now: when a parent wants to add crew, there will be an add crew button. Parent clicks on it and gets to a form which will query first and last name of the new user as well as the role. It will then be sent by email to the Admin.

    Later option or option B: parent can create new users who will be automatically linked to the parent's little thinker. in that case, I will need a random password generator so that the parent cannot get the password.

5. Admin can delete users who will then be removed from all crews too (can use the :on_delete option in migration)

6. If little thinker is removed the whole crew is removed (here, a check is needed: if crew members are
also little thinkers or followers of other thinkers they will not be removed from the user table; users who are just associated with
one little thinker will also be deleted from the user table)

There also needs to be a corresponding warning message before little thinker is deleted

7. Parents can delete crew. If a crew member is not also a little thinker or follower of other thinkers, they will 
at the same time be deleted from the user table.


## The create process

1. I am an Admin. Admin logs on. Goes to User Admin. Here all users are displayed.

2. User associations need to be displayed too.

3. Admin clicks on the register a new user tab.
goes to the user controller as before
If role is Little Thinker, user controller will call function in accounts.ex to link the little thinker to their own id

otherwise: 
User will be registered and re-direct to link crew.
Here, the new user's first and last name, will already be in the form.
Admin will enter the little thinker's name
upon submit: => crew controller where user will be linked to little thinker


# Data models

Users
relate to other users
Can follow other users as crew
Can control other users as Admin
Can add and remove crew as Parents

3 roles: Thinker, Crew, Admin





##### TO BE SOLVED: #####

Index page 


##### Tickets #####

# Create parent role

We need a new role of parent that has permissions over a little thinkers account.

Add `parent` role to User