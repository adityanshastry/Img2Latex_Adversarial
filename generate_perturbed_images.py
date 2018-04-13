import scipy.misc
import numpy as np
from numpy import genfromtxt
from os.path import isfile, join
from os import listdir


def save_perturbed_image(image_path, perturbations_path, perturbed_image_path):
    original_image = scipy.misc.imread(name=image_path, mode="L")
    perturbations = genfromtxt(perturbations_path, delimiter=",")
    scipy.misc.imsave(perturbed_image_path, original_image + perturbations)


def compute_and_save_perturbed_images(original_images_path, original_images, perturbations_path, perturbed_images_path):
	# TODO - get paths for images in original_images, get corresponding perturbations paths
	# call save_perturbed_image for all of them

