# data-drivers

## Cloning this Repository Locally

To work with this repository on your local machine, you need to clone it from the remote source.

1. **Ensure you have Git installed**  
   If Git is not installed on your system, download and install it for your OS from [git-scm.com](https://git-scm.com/).

2. **Set up SSH keys (optional but recommended)**  
   To securely communicate with GitHub (or your preferred Git hosting platform), it's recommended to set up SSH keys. Follow these steps:

    - [Generate an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) if you don’t already have one:
      ```bash
      ssh-keygen -t ed25519 -C "your_github_email@example.com"
      ```
    - Add the SSH key to your GitHub account by following the steps in [GitHub's documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

   **Note:** If you prefer HTTPS instead of SSH, you can skip this step.

3. **Clone the repository**  
   Open your terminal or command prompt in the directory of your choosing and execute the following command:

   ```bash
   git clone https://github.com/sethlors/data-drivers
   ```

4. **Verify and navigate into the project directory**  
   After cloning successfully, move into the project directory using the `cd` command:

   ```bash
   cd data-drivers
   ```

---

## Branch Protection and Contributions


We aim to keep this project organized and ensure high-quality contributions. Please follow these steps when contributing to the repository:

### 1. Creating a New Branch
Before making any changes, create a new branch for your work. This ensures the `main` branch remains stable and that changes can be reviewed effectively. Use the following steps:

1. **Fetch the latest changes from `main`:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create a new branch:**
   Branch names should be descriptive of the work being done. For example:
   ```bash
   git checkout -b feature/your-feature-name
   ```
   Examples of branch names:
    - `feature/add-api-methods`
    - `bugfix/fix-auth-issue`
    - `docs/update-readme`

3. **Work and commit on your branch:**
   Make your changes and commit them to your branch:
   ```bash
   git add .
   git commit -m "Descriptive message about your changes"
   ```

4. **Push your branch to the remote repository:**
   ```bash
   git push -u origin feature/your-feature-name
   ```


### 2. Submitting a Pull Request (PR)

Once your changes are ready, submit a pull request to merge them into the main branch. Follow these steps:

1. Go to the repository on GitHub.
2. Navigate to the **Pull Requests** tab.
3. Click **New Pull Request**.
4. Select your branch and compare it with `main`.
5. Write a clear title and description for your pull request, explaining the changes you made.
6. Submit your pull request for review.
7. Send the link to the pull request in the discord channel to be approved

### 3. Following Best Practices

- Write clear, concise, and meaningful commit messages.
- Keep your branch up-to-date by pulling from `main` regularly:
  ```bash
  git checkout main
  git pull origin main
  git checkout your-branch
  git merge main
  ```
- Ensure your code is linted before submitting a pull request.
