Random thoughts

1. can I delete the other md files now?
- Yes after making sure that you document important things in moduledocs that would be lost upon deletion

2. Navbar design: only have the elements that are not dependent on a little thinker in the top bar:
Profile, Settings, Contact (or user admin for Admin), Home (to be added) and Logout

3. Everything else would then be on the home page. 

4. What could a home page look like: 
for a little thinker:
button for Uploads
button for my crew
(if applicable: button for other little thinkers the little thinker follows)

5. For crew
They get to the little_thinkers index page first.
Then they choose a little thinker and then they get onto the home page.
Once that button is clicked, they get a button to uploads (of that little thinker),
a button to the crew (of that little thinker) if they are a parent and a button to a list with all their little thinkers (to switch teh space so to speak)

6. Could user Admin be something that could be moved to a GraphQL interface???
- This seems like really low priority

7. Maybe have a separate Admin controller?
So Admin would click on user Admin and have different options:

See all the users as before
but also an option to see all the relationships (and manipulate accordingly)

8. Still need to figure out new user registration and connection

9. Still need to figure out how an existing user gets connected with another little thinker.
- Have the admin handle this in DataGrip for now?

10. There will be a fixed order for the user registration:
Little Thinker first. Parent next. everybody else afterwards