function removeItem(list, item)
	for i = 1, #list do
		if list[i] == item then
			table.remove(list, i)
			return item
		end
	end
end
