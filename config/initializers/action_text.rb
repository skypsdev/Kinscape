Rails::Html::WhiteListSanitizer.allowed_tags += %w[audio video u]
Rails::Html::WhiteListSanitizer.allowed_attributes << 'controls'
