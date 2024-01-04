read -p "Enter the name of the database: " database;
/home/odoo/Documents/repo/odoo/odoo-bin --addons-path="~/Documents/repo/odoo/addons,~/Documents/repo/enterprise,~/Documents/repo/internal/default,~/Documents/repo/design-themes" --init="base,mrp,/mrp_subcontracting" --log-level="info" --test-enable --test-tags="mrp,/mrp_subcontracting" --stop-after-init --db-filter="$database";
