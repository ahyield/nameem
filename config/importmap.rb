# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/lib", under: "lib"
pin_all_from "app/javascript/api", under: "api"
pin "@fortawesome/fontawesome-free", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.1/js/all.js"
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@4.0.4/dist/tailwindcss-stimulus-components.module.js"
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.1.1/app/assets/javascripts/activestorage.esm.js"
pin "lexical", to: "https://esm.sh/lexical@0.28.0"
pin "@lexical/rich-text", to: "https://esm.sh/@lexical/rich-text@0.28.0?external=lexical"
pin "@lexical/link", to: "https://esm.sh/@lexical/link@0.28.0?external=lexical"
pin "@lexical/history", to: "https://esm.sh/@lexical/history@0.28.0?external=lexical"
pin "@lexical/selection", to: "https://esm.sh/@lexical/selection@0.28.0?external=lexical"
pin "@lexical/html", to: "https://esm.sh/@lexical/html@0.28.0?external=lexical,@lexical/selection"
pin "@lexical/utils", to: "https://esm.sh/@lexical/utils@0.28.0?external=lexical,@lexical/selection"
pin "@lexical/code", to: "https://esm.sh/@lexical/code@0.28.0?bundle-deps&external=lexical,@lexical/utils,@lexical/selection"
# Languages Prism doesn't ship with @lexical/code; they register on the global Prism it sets up
%w[ruby bash json yaml go].each do |language|
  pin "prismjs/components/prism-#{language}", to: "https://esm.sh/prismjs@1.30.0/components/prism-#{language}.js"
end
pin "@lexical/markdown",
    to: "https://esm.sh/@lexical/markdown@0.28.0?external=lexical,@lexical/code,@lexical/link,@lexical/rich-text,@lexical/utils,@lexical/selection"
pin "stimulus-clipboard", to: "https://ga.jspm.io/npm:stimulus-clipboard@4.0.1/dist/stimulus-clipboard.mjs"
pin "@fingerprintjs/fingerprintjs", to: "fingerprintjs.esm.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
