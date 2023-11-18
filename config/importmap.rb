# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'quill', to: 'https://ga.jspm.io/npm:quill@1.3.7/dist/quill.js'
pin 'buffer', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.1/nodelibs/browser/buffer.js'
pin '@fortawesome/fontawesome-free', to: 'https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.1/js/all.js'
pin 'tailwindcss-stimulus-components', to: 'https://ga.jspm.io/npm:tailwindcss-stimulus-components@4.0.4/dist/tailwindcss-stimulus-components.module.js'
pin '@rails/activestorage', to: 'https://ga.jspm.io/npm:@rails/activestorage@7.1.1/app/assets/javascripts/activestorage.esm.js'
pin "quill-delta-to-html", to: "https://ga.jspm.io/npm:quill-delta-to-html@0.12.1/dist/commonjs/main.js"
pin "lodash.isequal", to: "https://ga.jspm.io/npm:lodash.isequal@4.5.0/index.js"
pin "stimulus-clipboard", to: "https://ga.jspm.io/npm:stimulus-clipboard@4.0.1/dist/stimulus-clipboard.mjs"
