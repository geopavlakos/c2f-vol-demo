require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

dataset = arg[1]

set = 'valid'

if dataset == 'h36m' then
    -- Evaluation on users S9 and S11 of Human3.6M dataset
    -- Replicating results in our paper
    a = loadAnnotations('h36m')
    m = torch.load('c2f-volumetric-h36m.t7')   -- Load pre-trained model

elseif dataset == 'h36m-sample' then
    -- Small set of Human3.6M for action Posing_1 of subject S9 and camera 55011271 
    a = loadAnnotations('h36m-sample')
    m = torch.load('c2f-volumetric-h36m.t7')   -- Load pre-trained model

else
    print("Please use one of the following input arguments:")
    print("    h36m : Full test set of Human3.6M dataset (users S9 and S11)")
    print("    h36m-sample : Small set of Human3.6M")
    return
end
m:cuda()

idxs = torch.range(1,a.nsamples)

nsamples = idxs:nElement() 
-- Displays a convenient progress bar
xlua.progress(0,nsamples)
preds3D = torch.Tensor(1,17,3)
predHMs = torch.Tensor(1,17*64,64,64)

expDir = paths.concat('exp',dataset)
os.execute('mkdir -p ' .. expDir)

--------------------------------------------------------------------------------
-- Main loop
--------------------------------------------------------------------------------

for i = 1,nsamples do
    -- Set up input image
    local im = image.load('data/' .. dataset ..'/images/' .. a['images'][idxs[i]])
    local center = a['center'][idxs[i]]
    local scale = a['scale'][idxs[i]]
    local inp = crop(im, center, scale, 0, 256)

    -- Get network output
    local out3D = m:forward(inp:view(1,3,256,256):cuda())
    out3D = applyFn(function (x) return x:clone() end, out3D[#out3D])
    local flippedOut3D = m:forward(flip(inp:view(1,3,256,256):cuda()))
    flippedOut3D = applyFn(function (x) return flip(shuffleLR(x)) end, flippedOut3D[#flippedOut3D])
    out3D = applyFn(function (x,y) return x:add(y):div(2) end, out3D, flippedOut3D)
    cutorch.synchronize()

    predHMs:copy(out3D)
    preds3D:copy(getPreds3D(out3D))

    local predFile = hdf5.open(paths.concat(expDir, set .. '_' .. idxs[i] .. '.h5'), 'w')
    -- you can store the full 3D heatmap by uncommenting the next line
    --predFile:write('heatmaps', predHMs)
    predFile:write('preds3D', preds3D)
    predFile:close()

    xlua.progress(i,nsamples)

    collectgarbage()
end

