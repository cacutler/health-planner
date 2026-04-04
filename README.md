# Health Planner

This is a calorie/fitness tracking and workout planning project built with FastAPI/Python, PostgreSQL, and Flutter/Dart.

## Features

### Planned Features

- Calorie intake tracking (possibility for a food database API connection)
- Calorie Goal Logic
- Dashboard

### Possible Features

- Apple/Google Health integration
- Premium mobile features like progress rings

## REST Endpoints

| Name                          | Method | Path                                           | Router    |
| ----------------------------- | ------ | ---------------------------------------------- | --------- |
| Register a new user           | POST   | /auth/register                                 | Auth      |
| Login                         | POST   | /auth/token                                    | Auth      |
| Get workout exercises         | GET    | /workouts/{workout_id}/exercises               | Exercises |
| Create a workout exercise     | POST   | /workouts/{workout_id}/exercises               | Exercises |
| Update a workout exercise     | PATCH  | /workouts/{workout_id}/exercises/{exercise_id} | Exercises |
| Delete a workout exercise     | DELETE | /workouts/{workout_id}/exercises/{exercise_id} | Exercises |
| Get nutrition logs            | GET    | /nutrition                                     | Nutrition |
| Create a nutrition log        | POST   | /nutrition                                     | Nutrition |
| Get a single nutrition log    | GET    | /nutrition/{log_id}                            | Nutrition |
| Update a single nutrition log | PATCH  | /nutrition/{log_id}                            | Nutrition |
| Delete a single nutrition log | DELETE | /nutrition/{log_id}                            | Nutrition |
| Get user profile              | GET    | /users/me                                      | Users     |
| Update user profile           | PATCH  | /users/me                                      | Users     |
| Get weight logs               | GET    | /weight                                        | Weight    |
| Create a weight log           | POST   | /weight                                        | Weight    |
| Get a single weight log       | GET    | /weight/{weight_id}                            | Weight    |
| Delete a weight log           | DELETE | /weight/{weight_id}                            | Weight    |
| Update a weight log           | PATCH  | /weight/{weight_id}                            | Weight    |
| Get workouts                  | GET    | /workouts                                      | Workouts  |
| Create a workout              | POST   | /workouts                                      | Workouts  |
| Get a single workout          | GET    | /workouts/{workout_id}                         | Workouts  |
| Update a workout              | PATCH  | /workouts/{workout_id}                         | Workouts  |
| Delete a workout              | DELETE | /workouts/{workout_id}                         | Workouts  |

## Database Models

**User:**

- ID
- Email
- Password
- Height in inches
- Weight in pounds
- Birthdate for age calculation
- Sex
- Activity Level

**Workout:**

- ID
- User ID
- Duration Minutes
- Intensity
- Date

**Exercise:**

- ID
- Workout ID
- Name
- Sets
- Reps
- Weight

**Nutrition Log:**

- ID
- User ID
- Food Name
- Calories
- Protein
- Carbs
- Fat
- Date

**Weight Log:**

- ID
- User ID
- Weight
- Date