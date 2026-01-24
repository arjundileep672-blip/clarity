# Project TODO List

## Backend
### DataBase Structure
- [X] make a database of 3 models, `task_list`, `read_safe` and `buddy`
- [X] for every new session, new row should be created in the respective tables

### Task Deconstructor
- [X] when the user clicks on the "Task Deconstructor" button on the index page, the new row with session id should be added to db
- [X] and the user should be redirected to the Input page, which should support *text*, *audio*, *image*
- [ ] sending the input data to the AI model, via API
- [X] retrive the data, then arange the data as todo list checkboxes
- [ ] when user completes all the tasks, trigger the complition animation

### Sensory Safe Reading
- [X] when the user clicks on the "Read Safely" button on the index page, the new row with session id should be added to db
- [X] and the user should be redirected to the Input page, which should support *text*, *audio*, *image*
- [ ] sending the input data to the AI model, via API
- [ ] retrive the data, and display the data into the screen, with calm theme
- [ ] add when user clicks "Another Topic", redirect to the Input page section with new session id

### Socratic Buddy
- [X] when the user clicks on the "Socratic Buddy" it should redirect to the ChatBot page (with new session id), which greets him with something
- [ ] when user types something that should be saved in db, and also sent to the AI model
- [X] then should retrive the data from AI and display to that information to the user, and also save to the db
- [ ] and when user starts again from the index page, new chat with new session id should be created

## Froentend

## Extra
