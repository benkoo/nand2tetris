import pygame
import os, sys

import Image

pygame.init()

gameDisplay = pygame.display.set_mode((800,600))

pygame.display.set_caption('A bit Racey')

#if not pygame.image.get_extended():
#   raise SystemExit, "Sorry, extended image module required"

myImage = Image.open("assets/a1_0.bmp")

clock = pygame.time.Clock()

crashed = False

myColor = (1,1,1)

while not crashed:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            crashed = True

        print(event)

    gameDisplay.fill(myColor)

    pygame.display.update()




    clock.tick(60)

pygame.quit()

quit()
