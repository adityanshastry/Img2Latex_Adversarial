
def compare_preds_and_adversarial(preds, preds_adversarial):
    indexes = []
    for index, pred in enumerate(preds):
        if pred != preds_adversarial[index]:
            indexes.append(index)
    return indexes

def get_values(preds_file, preds_adversarial_file):
	images, preds, preds_adversarial, gold_labels = [], [], [], []
	with open(preds_file, "r") as res_fp:
	    for line in res_fp:
	        images.append(line.split("\t")[0])
	        gold_labels.append(line.split("\t")[1])
	        preds.append(line.split("\t")[2])
	with open(preds_adversarial_file, "r") as res_fp:
	    for line in res_fp:
	        preds_adversarial.append(line.split("\t")[2])
	return images, preds, preds_adversarial, gold_labels


images, preds, preds_adversarial, gold_labels = get_values("results/results.txt", "results_adversarial/results_LR_03.txt")
indexes = compare_preds_and_adversarial(preds, preds_adversarial)
