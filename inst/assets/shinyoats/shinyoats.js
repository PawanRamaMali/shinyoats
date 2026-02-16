/**
 * shinyoats - Shiny bindings for Oat UI components
 * Provides custom message handlers and input bindings for interactive components
 */

(function() {
  'use strict';

  // Wait for Shiny to be available
  $(document).on('shiny:connected', function() {
    initShinyOats();
  });

  function initShinyOats() {
    // Custom message handler: Update tabs
    Shiny.addCustomMessageHandler('shinyoats:updateTabs', function(message) {
      var tabs = document.getElementById(message.id);
      if (tabs && tabs.tagName === 'OT-TABS') {
        tabs.activeIndex = message.selected;
      }
    });

    // Custom message handler: Show modal
    Shiny.addCustomMessageHandler('shinyoats:showModal', function(message) {
      var modal = document.getElementById(message.id);
      if (modal && modal.tagName === 'DIALOG') {
        modal.showModal();
      }
    });

    // Custom message handler: Update modal
    Shiny.addCustomMessageHandler('shinyoats:updateModal', function(message) {
      var modal = document.getElementById(message.id);
      if (modal && modal.tagName === 'DIALOG') {
        if (message.action === 'show') {
          modal.showModal();
        } else if (message.action === 'hide') {
          modal.close();
        }
      }
    });

    // Custom message handler: Show toast
    Shiny.addCustomMessageHandler('shinyoats:toast', function(message) {
      if (window.ot && window.ot.toast) {
        window.ot.toast(
          message.message,
          message.title || null,
          {
            variant: message.variant || 'info',
            placement: message.placement || 'top-right',
            duration: message.duration !== undefined ? message.duration : 4000
          }
        );
      }
    });
  }

  // Re-initialize for dynamic UI
  $(document).on('shiny:reconnected', function() {
    initShinyOats();
  });

  // Handle dynamically added tabs
  if (window.MutationObserver) {
    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) {
            // Check if the node or its descendants contain ot-tabs
            var tabs = node.tagName === 'OT-TABS' ? [node] : node.querySelectorAll('ot-tabs');
            tabs.forEach(function(tab) {
              // Tabs will auto-initialize via connectedCallback
              // Just ensure Shiny knows about any inputs inside
              $(tab).find('.shiny-bound-input').trigger('change');
            });
          }
        });
      });
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // Optional: Tab change event listener to send to Shiny
  $(document).on('ot-tab-change', 'ot-tabs', function(e) {
    var detail = e.originalEvent ? e.originalEvent.detail : e.detail;
    var id = $(this).attr('id');

    if (id && Shiny && Shiny.setInputValue) {
      // Send tab index to Shiny (1-based)
      Shiny.setInputValue(id + '_selected', detail.index + 1);
    }
  });

  // Optional: Modal close event listener
  $(document).on('close', 'dialog', function(e) {
    var id = $(this).attr('id');

    if (id && Shiny && Shiny.setInputValue) {
      // Notify Shiny that modal was closed
      Shiny.setInputValue(id + '_closed', new Date().getTime());
    }
  });

})();
