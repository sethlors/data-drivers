# data-drivers

## Cloning this Repository Locally

To work with this repository on your local machine, you need to clone it from the remote source.

1. **Ensure you have Git installed**  
   If Git is not installed on your system, download and install it for your OS from [git-scm.com](https://git-scm.com/).

2. **Set up SSH keys (optional but recommended)**  
   To securely communicate with GitHub (or your preferred Git hosting platform), it's recommended to set up SSH keys.
   Follow these steps:

    - [Generate an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
      if you don’t already have one:
      ```bash
      ssh-keygen -t ed25519 -C "your_github_email@example.com"
      ```
    - Add the SSH key to your GitHub account by following the steps
      in [GitHub's documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

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

## Running Locally

To run the project locally, you need to have R and RStudio installed on your machine.

Assuming you have R and RStudio installed, install the following libraries:

```r
install.packages("shiny")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("plotly")
install.packages("here")
```

After installing the required packages, you can run the Shiny app by opening the shiny.R file in RStudio and clicking
the "Run App" button in the top right corner of the script editor. 
