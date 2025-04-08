# Prepared by Prof. Schaumont

import pya

print("Reading sealring GDS")
layout_sealring = pya.Layout()
#layermap_sealring = layout_sealring.read("sealring.gds")
layermap_sealring = layout_sealring.read("/opt/capri6/sealring.gds")

print("Reading chip layout GDS")
layout_capri = pya.Layout()
layermap_capri = layout_capri.read("../../outputs_icc2/six_core_msp430_scan_with_pads_postlayout_test_merged.gds")

print("Old Top Cell: ", layout_capri.cell("six_core_msp430_scan_with_pads").basic_name())
layout_sealring.top_cell().name = "capri6"
print("New Top Cell: ", layout_sealring.top_cell().basic_name())

source_capri_cell = layout_capri.cell("six_core_msp430_scan_with_pads")
target_capri_cell = layout_sealring.top_cell()

cm = pya.CellMapping()
cm.for_single_cell_full(target_capri_cell, source_capri_cell)
layout_sealring.copy_tree_shapes(layout_capri, cm)

t = pya.Trans(98000,98000)
layout_sealring.top_cell().transform(t)

print("Merged Layout: capri.gds")
layout_sealring.write("capri.gds")

