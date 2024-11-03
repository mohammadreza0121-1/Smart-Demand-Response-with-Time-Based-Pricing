# Smart-Demand-Response-with-Time-Based-Pricing



# Time of Use Demand Response Program

## Overview
This project implements a **Demand Response (DR)** program using **Time of Use (TOU) pricing** to help manage electricity consumption for a simulated residential network of 200 homes. The program includes optimized load responses for various types of loads, such as lighting, HVAC, and refrigeration, in response to time-based electricity prices.

The goal is to efficiently reduce peak demand, lower energy usage, and provide cost savings through dynamic adjustments in response to changing electricity prices.

## Project Structure

The project includes the following main scripts:

1. **Base Load Model (base_load_model.m)**:
   - This script models the baseline load curve without any demand response programs.
   - It generates and saves baseline load profiles for different types of loads.
   - The baseline profile serves as a reference to evaluate the effectiveness of demand response strategies.

2. **Time of Use Demand Response Program (time_of_use_dr.m)**:
   - Implements the demand response program based on TOU pricing, with adaptive load responses.
   - Adjusts consumption for lighting, HVAC, and refrigeration loads based on TOU prices.
   - It calculates key performance metrics, including peak demand reduction, energy savings, and cost savings.

## Key Features

- **Time of Use Pricing**: TOU prices vary hourly to encourage lower energy usage during peak hours.
- **Dynamic Load Adjustments**:
  - **Lighting**: Reduces consumption during peak hours based on individual home thresholds.
  - **HVAC**: Adjusts consumption with a combination of time-of-day and price-based factors.
  - **Refrigeration**: Implements load shifting to non-peak hours with minimal impact on cooling.
- **Performance Metrics**:
  - Peak demand reduction
  - Total energy savings
  - Cost savings

## Usage

1. **Run Base Load Model**: 
   - Execute `base_load_model.m` to generate and save baseline load profiles.

2. **Run Demand Response Program**:
   - Run `time_of_use_dr.m` to apply demand response strategies using TOU pricing.

3. **View Results**:
   - Each script provides visualizations of load profiles, including baseline and adjusted load curves.
   - Metrics such as peak reduction, energy savings, and cost savings are calculated and displayed.

## Results

The TOU Demand Response Program demonstrates how electricity usage can be optimized based on pricing signals, reducing overall demand during peak hours and providing significant savings.

## License
This project is licensed under the MIT License.
