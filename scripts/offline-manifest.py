"""Write capabilities, plugin revisions, and selected tools to the offline manifest."""
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
manifest = json.loads((root / 'manifest.json').read_text())
manifest['selection'] = json.loads((root / 'runtime/config-plan.json').read_text())
manifest['plugin_versions'] = json.loads((root / 'runtime/config/nvim/lazy-lock.json').read_text())
manifest['tool_receipts'] = {
    receipt.parent.name: json.loads(receipt.read_text())
    for receipt in (root/'runtime/data/nvim/mason/packages').glob('*/mason-receipt.json')
}
(root / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
