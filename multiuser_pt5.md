00. Make a markdown file with all the navigation code I am deleting for reference
0. Remove all links that pertain to the little thinker from the navbar

0.1 Change the design of the "home" page.

- For regular users: button "choose your little thinker" -> leads to little_thinker_index
- If current.user role == Little Thinker, have link "enter my space" -> little_thinker_show
[later on, I can add choose my little thinker button here as well]

0.1.1 Make it so that the button for choosing a little thinker only appears to a little thinker if he has other little thinkers

0.2 Create a little_thinker_show_page
- Link to little_thinker_Profile (if it exists)
- link to uploads

if parent:
link to crew


if user === little thinker
link to crew
link to uploads





2. Parents need to be able to see their little thinker's crew

3. Parents will have the option to remove or add crew members (should little thinker have that option as well)?
What I envision is that both the link to add and remove crew member leads to a crew form.
In the remove form, the parent will enter the crews first and last name and submit. Form will be sent to admin, who will remove crew.
If crew is not connected to anyone else, user will be deleted.

If parents want to add a crew member, they will enter the first and last name plus email of the new crew member, as well as the crew's relationship to the little thinker.
Form will be sent to Admin.

Admin can create the new user in the online interface and connect them to the lt in datagrip.


4. Figure out how to best arrange the navigation elements with focus on what regular (non-Admin) users see.

5. Create a second little thinker for demo purposes. create some crew. make sure it works.

6. Create demo content

7. Make a nice little video

8. Find a way to play video on the little_thinkers index page