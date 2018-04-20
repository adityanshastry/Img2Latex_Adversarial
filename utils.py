import scipy.misc
import numpy as np
from numpy import genfromtxt
from os.path import isfile, join
from os import listdir
import matplotlib.pyplot as plt


def compare_preds_and_adversarial(preds, preds_adversarial):
    indexes = []
    for index, pred in enumerate(preds):
        if pred != preds_adversarial[index]:
            indexes.append(index)
    return indexes

def get_values(preds_file):
    images, preds, gold_labels = [], [], []
    with open(preds_file, "r") as res_fp:
        for line in res_fp:
            images.append(line.split("\t")[0])
            gold_labels.append(line.split("\t")[1])
            preds.append(line.split("\t")[2])
    return images, preds, gold_labels


def save_perturbed_image(image_path, perturbations_path, perturbed_image_path):
    original_image = scipy.misc.imread(name=image_path, mode="L")
    perturbations = genfromtxt(perturbations_path, delimiter=",")
    scipy.misc.imsave(perturbed_image_path, original_image + perturbations)


def plot_loss_vs_epoch(loss_file):
	losses = []
	with open(loss_file, "r") as loss_fp:
		for line in loss_fp:
			losses.append(float(line))
	plt.plot(range(len(losses)), losses)
	plt.show()


def main():
	# images, preds, gold_labels = get_values("results/results.txt")
	# images, preds_adversarial, gold_labels = get_values("results_adversarial/results_LR_03.txt")
	# indexes = compare_preds_and_adversarial(preds, preds_adversarial)
	plot_loss_vs_epoch("logs/non_targeted_test.log")


if __name__ == '__main__':
	main()
