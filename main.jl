using Images
using DataFrames
using Statistics 
using DataFrames
using CSV
using DecisionTree

function read_data(type_data, labelsInfo, imageSize, path)
    x = zeros(size(labelsInfo, 1), imageSize)
    for (index, idImage) in enumerate(labelsInfo.ID)
        nameFile = "$(path)/$(type_data)Resized/$(idImage).Bmp"
        img = load(nameFile)
        temp = float32(img)
        temp = Gray.(temp)
        x[index, :] = reshape(temp, 1, imageSize)
    end
    return x
end


imageSize = 400
path = "..."
labelsInfoTrain = CSV.read("$(path)/trainLabels.csv")
xTrain = read_data("train", labelsInfoTrain, imageSize, path)
labelsInfoTest = CSV.read("$(path)/sampleSubmission.csv")
xTest = read_data("test", labelsInfoTest, imageSize, path)
yTrain = map(x -> x[1], labelsInfoTrain.Class)
yTrain = Int.(yTrain)


model = build_forest(yTrain, xTrain, 20, 50, 1.0)
predTest = apply_forest(model, xTest)
labelsInfoTest.Class = Char.(predTest)
CSV.write("$(path)/juliaSubmission.csv", labelsInfoTest, header=true)
accuracy = nfoldCV_forest(yTrain, xTrain, 20, 50, 4, 1.0);
println("4 fold accuracy: $(mean(accuracy))")

