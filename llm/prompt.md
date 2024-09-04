write a ruby tool to load the $HOME/.babybrorc yaml file (example in babrorc.example) and update it.

tool functions will be:
1.  Add new project
- Use CWD as default directory
- Send README.* and directory name to LLM to get a default project name
- Prompt user for Project Name and Directory using defaults as starting point
- Save the updated .babybrorc file

2. Remove a project
- Prompt user for project name, showing a numbered list of projects, and asking user to enter the number of the project to remove
- Remove the project from the .babybrorc file
- Save the updated .babybrorc file

3. Update a project
- Prompt user for project name, showing a numbered list of projects, and asking user to enter the number of the project to update
- Prompt user for new project name
- Prompt user for new project directory
- Remove the project from the .babybrorc file
- Save the updated .babybrorc file

4. List projects
- Load the .babybrorc file
- Print a numbered list of projects to the console
- Print the project name, directory, and README.* file contents to the console

5. Exit
- Exit the tool

Create a loop that will allow the user to perform these functions.  CTRL-C will exit a given function if not completed.  If no function is currently active, the loop will end and the program will exit.

For the LLM projecy name creation, use OpenAI's API with the following prompt:
<<<
I will provide a directory path and a README file.  I want you to respond with a project name.

Directory: {directory}
README:
{readme}
>>>

Use the gpt-4o-mini model.
Use the OPENAI_API_KEY environment variable to authenticate.

To implement the described Ruby tool, follow these steps:

1. **Setup and Initialization**:
   - Load the YAML file located at `$HOME/.babybrorc`.
   - Ensure the OpenAI API key is available from the environment variable `OPENAI_API_KEY`.

2. **Add New Project**:
   - Use the current working directory (CWD) as the default directory.
   - Read the `README.*` file in the CWD.
   - Send the directory path and `README.*` contents to the LLM using OpenAI's API with the specified prompt and model (`gpt-4o-mini`).
   - Prompt the user for a project name and directory, using the LLM-generated name and CWD as defaults.
   - Update the YAML file with the new project details.
   - Save the updated YAML file.

3. **Remove a Project**:
   - Load the projects from the YAML file.
   - Display a numbered list of projects to the user.
   - Prompt the user to enter the number of the project to remove.
   - Remove the selected project from the YAML data.
   - Save the updated YAML file.

4. **Update a Project**:
   - Load the projects from the YAML file.
   - Display a numbered list of projects to the user.
   - Prompt the user to enter the number of the project to update.
   - Prompt the user for a new project name and directory.
   - Update the selected project's details in the YAML data.
   - Save the updated YAML file.

5. **List Projects**:
   - Load the projects from the YAML file.
   - Print a numbered list of projects, including their names, directories, and the contents of their `README.*` files.

6. **Exit**:
   - Provide an option for the user to exit the tool.

7. **Main Loop**:
   - Create a loop that presents the user with a menu of options (Add, Remove, Update, List, Exit).
   - Execute the corresponding function based on the user's selection.
   - Allow the user to interrupt (e.g., with CTRL-C) to exit the current function or the entire tool if no function is active.

These steps outline the structure and functionality required to build the Ruby tool as described. Each function will interact with the YAML file and, where necessary, the OpenAI API to manage project data.