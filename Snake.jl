using PyCall

let
    
println("Before we start, here's a word from our engine, pygame:")
# Use pycall to import pygame
pygame = pyimport("pygame")

pygame.init()

# define basic colors
white = (255, 255, 255)
black = (0, 0, 0)
red = (255, 0, 0)
green = (76, 175, 80)

# define screen_size, block_size, speed, FPS etc.
screen_size = (400, 400)
block_size = 20

max_speed = 20

FPS = 5

# Import all different sprites
img = pygame.image.load("./sprites/head.png")
head_1 = pygame.image.load("./sprites/head_1.png")

apple_img = pygame.image.load("./sprites/apple.png")

# Setup game window
game_display = pygame.display.set_mode(screen_size)
pygame.display.set_caption("Snake")
clock = pygame.time.Clock()

game_exit = false

# Start snake at middle of screen
head_x = (screen_size[1] / 2) - block_size
head_y = (screen_size[2] / 2) - block_size
x_speed = 0
y_speed = 0

# Define function to draw snake
function snake(snake_list, block_size)
    # Load appropriate image for head according to size of snake and orientation of snake
    head = img

    if length(snake_list) == 1
        head = head_1
        if x_speed > 0
            head = pygame.transform.rotate(head_1, 270)
        elseif x_speed < 0
            head = pygame.transform.rotate(head_1, 90)
        elseif y_speed > 0
            head = pygame.transform.rotate(head_1, 180)
        elseif y_speed < 0
            head = head_1
        end
    else
        head = img
    # Rotate snake head according to where snake is heading
        if x_speed > 0
            head = pygame.transform.rotate(img, 270)
        elseif x_speed < 0
            head = pygame.transform.rotate(img, 90)
        elseif y_speed > 0
            head = pygame.transform.rotate(img, 180)
        elseif y_speed < 0
            head = img
        end
    end
    # Draw image for head, and render the rest of the snake as rects
    game_display.blit(head, snake_list[end])
    for snake_block in snake_list[1:end - 1]
        game_display.fill(green, rect = [snake_block[1], snake_block[2], block_size, block_size])
    end
end

# Create function to get user input and recursively validate the user input
function get_input(text_to_print, in_same_line, allowed_options, required_params)

    # If we want to print on the same line, use `print()`. Else, `use println()`
    in_same_line ? print(text_to_print) : println(text_to_print)

    # Get input and split it into an array
    txtin = split(lowercase(readline()));

    # If the required amount of parameters is not met or if the command is not in the list of allowed options,
    # ask for input again
    if length(txtin) < required_params || !(txtin[1] in allowed_options)
        println("Please enter a valid command (see README)")
        get_input(text_to_print, in_same_line, allowed_options, required_params)
    else
        # If input is valid, return the input as a string.
        return join(txtin, " ")
    end
end

# Ask if user wants to play_again
function play_again()

    ans = get_input("Play again? (y/n): ", true, ["y", "n"], 1)

    # If user wants to play again, run the game again. Else, exit()
    if ans == "y"
        run(`julia $PROGRAM_FILE`)
        pygame.quit()
        exit()
    else
        exit()
    end
end

# Start game
function game_loop(color_mode)
    # Decide random position of apple
    apple_pos = (rand(0 : (screen_size[1] / block_size) - 1) * block_size, rand(0 : (screen_size[1] / block_size) - 1) * block_size)

    # init snake
    snake_list = []

    # Size of snake
    score = 1

    # While user is not exiting, play game
    while !game_exit
        # Check every event pyagem gets
        for event in pygame.event.get()
            # If user wants to quit, quit
            if event.type == pygame.QUIT
                return score
            end

            # According to key pressed, move snake
            if event.type == pygame.KEYDOWN
                if event.key == pygame.K_LEFT
                    x_speed = -max_speed
                    y_speed = 0
                elseif event.key == pygame.K_RIGHT
                    x_speed = max_speed
                    y_speed = 0
                elseif event.key == pygame.K_DOWN
                    x_speed = 0
                    y_speed = max_speed
                elseif event.key == pygame.K_UP
                    x_speed = 0
                    y_speed = -max_speed
                end
            end
                    
        end

        # Move snake's head position
        head_x += x_speed
        head_y += y_speed

        # Draw the background
        if color_mode == "1"
            game_display.fill(white)
        else
            game_display.fill(black)
        end
        
        # Draw apple sprite at random location
        game_display.blit(apple_img, [apple_pos[1], apple_pos[2], block_size, block_size])

        # Put snake's head in snake_list
        snake_head = [head_x, head_y]
        push!(snake_list, snake_head)

        # If the snake positions that we store are more than the length, remove them (the positions are no more snake_segments)
        if length(snake_list) > score
            deleteat!(snake_list, 1)
        end

        # Loop snake back into game
        for snake_segment in snake_list
            snake_segment[1] >= 0 ? snake_segment[1] %= screen_size[1] : snake_segment[1] = screen_size[1] - snake_segment[1]
            snake_segment[2] >= 0 ? snake_segment[2] %= screen_size[2] : snake_segment[2] = screen_size[2] - snake_segment[2]
        end

        # Loop head back into game
        head_x > 0 ? head_x %= screen_size[1] : head_x = screen_size[1] - head_x
        head_y > 0 ? head_y %= screen_size[2] : head_y = screen_size[2] - head_y

        # If any snake_segment except head is touching head, end game
        for snake_segment in snake_list[1: end - 1]
            if snake_segment == snake_list[end]
                return score
            end
        end

        # Render snake
        snake(snake_list, block_size)
            
        # Update display
        pygame.display.update()

        # If snake eats apple, increment score by 1, and draw new apple
        for snake_segment in snake_list
            if snake_segment[1] == apple_pos[1] && snake_segment[2] == apple_pos[2]
                apple_pos = (rand(0 : (screen_size[1] / block_size) - 1) * block_size, rand(0 : (screen_size[1] / block_size) - 1) * block_size)
                score += 1
            end
        end

        # Wait for 1/FPS seconds
        clock.tick(FPS)
    end
end

a = """
Hi! Welcome to Snake. Before we start, here's some instructions:
- Don't run into yourself
- Running into the walls loops you back into the screen
- Eat as many apples as you can
- Press any arrow key to start playing

"""
println(a)

mode = get_input("Would you like to play in light mode (1) or dark mode (2)?", false, ["1", "2"], 1)

# Run game
user_score = game_loop(mode)

println("Your score was: $user_score")

play_again()
end