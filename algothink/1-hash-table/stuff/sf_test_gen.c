#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to generate a random number between min and max (inclusive)
int random_range(int min, int max) {
    return min + rand() % (max - min + 1);
}

// Function to generate a single snowflake
void generate_snowflake(int snowflake[6], int max_arm_length) {
    for (int i = 0; i < 6; i++) {
        snowflake[i] = random_range(0, max_arm_length - 1);
    }
}

// Function to rotate a snowflake array by n positions
void rotate_snowflake(int original[6], int rotated[6], int positions) {
    for (int i = 0; i < 6; i++) {
        rotated[i] = original[(i + positions) % 6];
    }
}

// Function to reverse a snowflake
void reverse_snowflake(int original[6], int reversed[6]) {
    for (int i = 0; i < 6; i++) {
        reversed[i] = original[5 - i];
    }
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <num_snowflakes> <max_arm_length> <twin_probability>\n", argv[0]);
        printf("Example: %s 1000 1000000 20\n", argv[0]);
        return 1;
    }

    // Parse command line arguments
    int n = atoi(argv[1]);                    // Number of snowflakes
    int max_arm_length = atoi(argv[2]);       // Maximum arm length
    int twin_prob = atoi(argv[3]);            // Probability of generating twins (0-100)

    // Validate input
    if (n <= 0 || n > 100000) {
        printf("Number of snowflakes must be between 1 and 100,000\n");
        return 1;
    }
    if (max_arm_length <= 0 || max_arm_length > 10000000) {
        printf("Maximum arm length must be between 1 and 10,000,000\n");
        return 1;
    }
    if (twin_prob < 0 || twin_prob > 100) {
        printf("Twin probability must be between 0 and 100\n");
        return 1;
    }

    // Seed the random number generator
    srand(time(NULL));

    // Generate and print the number of snowflakes
    printf("%d\n", n);

    // Arrays to store snowflakes temporarily
    int snowflake[6];
    int twin[6];

    // Generate snowflakes
    for (int i = 0; i < n; i++) {
        // Decide whether to generate a twin
        int generate_twin = (rand() % 100) < twin_prob && i < n - 1;

        if (generate_twin) {
            // Generate original snowflake
            generate_snowflake(snowflake, max_arm_length);

            // Randomly decide whether to rotate or reverse the twin
            if (rand() % 2 == 0) {
                // Rotate by random positions
                rotate_snowflake(snowflake, twin, random_range(1, 5));
            } else {
                // Reverse and potentially rotate
                reverse_snowflake(snowflake, twin);
                if (rand() % 2 == 0) {
                    int temp[6];
                    rotate_snowflake(twin, temp, random_range(1, 5));
                    for (int j = 0; j < 6; j++) {
                        twin[j] = temp[j];
                    }
                }
            }

            // Print original snowflake
            for (int j = 0; j < 6; j++) {
                printf("%d", snowflake[j]);
                printf(j < 5 ? " " : "\n");
            }

            // Print twin snowflake
            i++;  // Increment i since we're printing two snowflakes
            for (int j = 0; j < 6; j++) {
                printf("%d", twin[j]);
                printf(j < 5 ? " " : "\n");
            }
        } else {
            // Generate and print a unique snowflake
            generate_snowflake(snowflake, max_arm_length);
            for (int j = 0; j < 6; j++) {
                printf("%d", snowflake[j]);
                printf(j < 5 ? " " : "\n");
            }
        }
    }

    return 0;
}
