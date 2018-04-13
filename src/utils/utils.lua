tds = require('tds')

if logging ~= nil then
    log = function(msg) logging:info(msg) end
else
    log = print
end
-- http://stackoverflow.com/questions/17119804/lua-array-shuffle-not-working
function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function shuffle(array)
    local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        swap(array, index, counter)
        counter = counter - 1
    end
end

function trim(str)
    local newstr = str:match( "^%s*(.-)%s*$" )
    return newstr
end

function split(str)
    local t = {}
    for v in string.gmatch(str, "[^%s]+") do
        table.insert(t, v)
    end
    return t
end

function reset_state(state, batch_l, t)
    if t == nil then
        local u = {}
        for i = 1, #state do
            state[i]:zero()
            table.insert(u, state[i][{{1, batch_l}}])
        end
        return u
    else
        local u = {[t] = {}}
        for i = 1, #state do
            state[i]:zero()
            table.insert(u[t], state[i][{{1, batch_l}}])
        end
        return u
    end      
end

-- https://gist.github.com/Badgerati/3261142
-- Returns the Levenshtein distance between the two given strings
function string.levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	
        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	
        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

function localize(thing)
    assert (use_cuda ~= nil, 'use_cuda must be set!')
    if use_cuda then
        return thing:cuda()
    end
    return thing
end

function numlist2str(label_list, visualize)
    local visualize = visualize or false
    local str = tds.Vec()
    local strlist = tds.Vec()
    for i = 1, #label_list do
        local vocab_id = label_list[i]
        --print (vocab_id)
        if vocab_id <= 3 then
            break
        end
        local l = id2vocab[vocab_id-4]
        if vocab_id == 4 then
            l = 'UNK'
        end
        assert (l ~= nil, 'target vocab size incorrect!')
        if visualize then
            strlist:insert(l)
        end
        if l ~= nil then
            for c in l:gmatch"." do
                str:insert(c)
            end
        end
        str:insert(' ')
    end
    label_str = str:concat()
    return label_str, strlist
end

vocab2id = nil
label_lines = nil
function path2numlist(file_path, label_path)
    if vocab2id == nil then
        vocab2id = tds.Hash()
        for i = 1, #id2vocab do
            vocab2id[id2vocab[i]] = i+4
        end
    end
    if label_lines == nil then
        label_lines = tds.Hash()
        local file, err = io.open(label_path, "r")
        if err then
            logging:info(string.format('ERROR: label path %s does not exist!', label_path))
            os.exit()
        end
        for line in file:lines() do
            local strlist = split(trim(line))
            local strlist_tds = tds.Vec()
            for i = 1, #strlist do
                strlist_tds[#strlist_tds+1] = strlist[i]
            end
            label_lines[#label_lines+1] = strlist_tds
        end
    end
    local numlist = tds.Hash()
    numlist[1] = 2
    local strlist = label_lines[tonumber(file_path)+1]
    for i = 1, #strlist do
        local token = strlist[i]
        if vocab2id[token] ~= nil then
            numlist[#numlist+1] = vocab2id[token]
        else
            numlist[#numlist+1] = 4
        end
    end
    numlist[#numlist+1] = 3
    return numlist
end

function evalHTMLErrRate(labels, target_labels, visualize)
    local batch_size = labels:size()[1]
    local target_l = labels:size()[2]
    assert(batch_size == target_labels:size()[1])
    assert(target_l == target_labels:size()[2])

    local word_error_rate = 0.0
    local labels_pred = {}
    local labels_gold = {}
    local labels_list_pred = {}
    local labels_list_gold = {}
    for b = 1, batch_size do
        local label_list = {}
        for t = 1, target_l do
            local label = labels[b][t]
            if label == 3 then
                break
            end
            table.insert(label_list, label)
        end
        local target_label_list = {}
        for t = 1, target_l do
            local label = target_labels[b][t]
            if label == 3 then
                break
            end
            table.insert(target_label_list, label)
        end
        local label_str, label_strlist = numlist2str(label_list, visualize)
        local target_label_str, target_label_strlist = numlist2str(target_label_list, visualize)
        if visualize then
            table.insert(labels_pred, label_str)
            table.insert(labels_gold, target_label_str)
            table.insert(labels_list_pred, label_strlist)
            table.insert(labels_list_gold, target_label_strlist)
        end
        local edit_distance = string.levenshtein(label_str, target_label_str)
        --if edit_distance ~= 0 then
        --    word_error_rate = word_error_rate + 1
        --end
        word_error_rate = word_error_rate + math.min(1,edit_distance / string.len(target_label_str))
    end
    return word_error_rate, labels_pred, labels_gold, labels_list_pred, labels_list_gold
end


function slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end


function get_data_directory_from_path(data_path)

    local data_path_components = data_path:split("/")
    return "/"..table.concat(slice(data_path_components, 1, #data_path_components-1), "/")

end


function backup_adversarial_perturbations_for_epoch(data_path, epoch)

    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"
    local backup_adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations_"..tostring(epoch).."/"
    os.execute(string.format("cp -R %s %s", adversarial_perturbations_data_directory, backup_adversarial_perturbations_data_directory))

end


function initialize_adversarial_perturbations(data_path)
    local file = io.open(data_path)
    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"
    local perturbed_images_path = {}

    if file then
        for line in file:lines() do
            image_name, _ = unpack(line:split(" "))
            image_title = image_name:sub(1, #image_name-4)
            perturbed_image_path = adversarial_perturbations_data_directory..image_title..".csv"
            perturbed_image_file = io.open(perturbed_image_path, "w")
            perturbed_image_file:close()

        end
    else
        -- exception case
    end

end


function get_file_size(file)
    local current = file:seek()
    local size = file:seek("end")
    file:seek("set", current)
    return size
end


function get_adversarial_perturbations_from_path(adversarial_perturbations_file_name, adversarial_perturbation)

    local adversarial_perturbations_file = io.open(adversarial_perturbations_file_name, "r")
    local adversarial_perturbations_file_size = get_file_size(adversarial_perturbations_file)
    if adversarial_perturbations_file_size ~= 0 then
        local i = 0
        for line in adversarial_perturbations_file:lines('*l') do
            i = i + 1
            local l = line:split(',')
            for key, val in ipairs(l) do
                adversarial_perturbation[i][key] = val
            end
        end
    end

    adversarial_perturbations_file.close()
    return adversarial_perturbation

end


function load_adversarial_perturbations(adversarial_perturbations_file_names, adversarial_perturbations, data_path)

    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"

    for file_name_index = 1, #adversarial_perturbations_file_names do
        local image_name = adversarial_perturbations_file_names[file_name_index]
        local image_title = image_name:sub(1, #image_name-4)
        local adversarial_perturbations_file_name = adversarial_perturbations_data_directory..image_title..".csv"
        adversarial_perturbations[file_name_index][1] = get_adversarial_perturbations_from_path(adversarial_perturbations_file_name, adversarial_perturbations[file_name_index][1]):clone()
    end

    return adversarial_perturbations

end


function save_adversarial_perturbations(adversarial_perturbations_file_names, adversarial_perturbations, data_path)

    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"
    local adversarial_perturbations_size = adversarial_perturbations:size()
    
    for file_name_index = 1, #adversarial_perturbations_file_names do
        local image_name = adversarial_perturbations_file_names[file_name_index]
        local image_title = image_name:sub(1, #image_name-4)
        local adversarial_perturbations_file_name = adversarial_perturbations_data_directory..image_title..".csv"

        local adversarial_perturbations_file = io.open(adversarial_perturbations_file_name, "w")

        splitter = ","
        for i=1, adversarial_perturbations_size[3] do
            for j=1, adversarial_perturbations_size[4] do
                adversarial_perturbations_file:write(adversarial_perturbations[file_name_index][1][i][j])
                if j == adversarial_perturbations_size[4] then
                    adversarial_perturbations_file:write("\n")
                else
                    adversarial_perturbations_file:write(splitter)
                end
            end
        end
    end

end


function initialize_adversarial_tensors_dictionary(data_path)

    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"

    for file_name_index = 1, #adversarial_perturbations_file_names do
        local image_name = adversarial_perturbations_file_names[file_name_index]
        local image_title = image_name:sub(1, #image_name-4)
        local adversarial_perturbations_file_name = adversarial_perturbations_data_directory..image_title..".csv"
        adversarial_perturbations[file_name_index][1] = get_adversarial_perturbations_from_path(adversarial_perturbations_file_name, adversarial_perturbations[file_name_index][1]):clone()
    end


    local file = io.open(data_path)
    adversarial_perturbations_dict = {}

    if file then
        for line in file:lines() do
            image_name, _ = unpack(line:split(" "))
            adversarial_perturbations_dict[image_name] = nil
            local image_title = image_name:sub(1, #image_name-4)
            local adversarial_perturbations_file_name = adversarial_perturbations_data_directory..image_title..".csv"
            local adversarial_perturbations_file = io.open(adversarial_perturbations_file_name, "r")


        end
    else
        -- exception case
    end

    return adversarial_perturbations_dict

end


function get_adversarial_tensors_from_images(image_names, batch_tensor_size, adversarial_perturbations_dict)
    
    local adversarial_perturbations_tensor = torch.Tensor(batch_tensor_size):zero()
    print (#image_names)
    print (batch_tensor_size)

    for image_index = 1, #image_names do
        local image_name = image_names[image_index]
        if adversarial_perturbations_dict[image_name] == nil then
            adversarial_perturbations_dict[image_name] = torch.Tensor(batch_tensor_size[3], batch_tensor_size[4]):zero()
        else
            adversarial_perturbations_tensor[image_index][1] = adversarial_perturbations_dict[image_name]:clone()
        end
    end

    return adversarial_perturbations_tensor

end


function update_adversarial_perturbations_dict(image_names, adversarial_perturbations, adversarial_perturbations_dict)

    for image_index = 1, #image_names do
        local image_name = image_names[image_index]
        adversarial_perturbations_dict[image_name] = adversarial_perturbations[image_index][1]:clone()
    end

    return adversarial_perturbations_dict

end


function save_adversarial_tensors(data_path, adversarial_perturbations_dict)

    local adversarial_perturbations_data_directory = get_data_directory_from_path(data_path).."/adversarial_perturbations/"

    for image_name, adversarial_tensor in pairs(adversarial_perturbations_dict) do
        local image_title = image_name:sub(1, #image_name-4)
        local adversarial_perturbations_file_name = adversarial_perturbations_data_directory..image_title..".csv"
        local adversarial_perturbations_file = io.open(adversarial_perturbations_file_name, "w")

        splitter = ","
        for i=1, adversarial_tensor:size()[1] do
            for j=1, adversarial_tensor:size()[2] do
                adversarial_perturbations_file:write(adversarial_tensor[i][j])
                if j == adversarial_tensor:size()[2] then
                    adversarial_perturbations_file:write("\n")
                else
                    adversarial_perturbations_file:write(splitter)
                end
            end
        end        
    end

end




