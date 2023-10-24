# Tech Assessment - movie-finder

Welcome to the tech assessment for the `movie-finder` project. This README provides instructions for setting up the environment and includes some insights about the development process.

## Setting up the Environment

To get started with the `movie-finder` project, follow these setup instructions:

1. Clone the repository:
   ```
   git clone git@github.com:adamFoldvari/movie_finder.git
   ```
2. Install the necessary gems using Bundler:
   ```
    bundle install
   ```
3. Start up Docker Composer:
   ```
   docker-compose up
   ```
4. Now you should be able to run the build:
   ```
   bundle exec rake
   ```

## Additional Information

Here's some important information about this tech assessment:

**Development Time**:
- The project was completed in approximately 2 working days, totaling 16 hours.

**Testing Approach**:
- Test-Driven Development (TDD) was used throughout the development process to ensure code quality and functionality.

**Deployment**:
- The application is live on Heroku, accessible at this URL: [https://adam-movie-finder-7f9c799fa768.herokuapp.com/](https://adam-movie-finder-7f9c799fa768.herokuapp.com/)

**Development Decisions**:
- Please keep in mind that the decisions made during this assessment were tailored to fit the specific requirements and constraints of this smaller project. In a real-life scenario with different demands, different decisions might have been considered. These choices were optimized to meet the objectives and scope of the assessment.
    - **Cache Service**:
        - Initially, Redis was chosen as the caching service, but for Heroku deployment, MemCachier was selected for its free caching option.
    - **UI Rendering**:
        - Server-side UI rendering was used due to the straightforward nature of the frontend, eliminating the need for complex JavaScript.
    - **Testing Strategy**:
        - Request tests were employed to test the controller and view. This aligns with the default test type Rails generates for resources, offering comprehensive testing of the entire resource, including routes, controller actions, and associated views.

Feel free to explore the codebase and follow the setup instructions above to run the project. If you have any questions or need assistance, please don't hesitate to contact us.

Thank you for your time and consideration!