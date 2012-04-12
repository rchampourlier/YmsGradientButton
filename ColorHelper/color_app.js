$(function() {
	
	var Color = Backbone.Model.extend({
		clear: function() {
			this.destroy();
		}
	});
	
	var ColorDrawer = Backbone.Collection.extend({
		model: Color,
		localStorage: new Store("color-drawer"),
	});
	
	var Colors = new ColorDrawer;
	
	var ColorView = Backbone.View.extend({
		
		tagName: "li",
		
		events: {
			"click" : "show",
		},
		
		initialize: function() {
      this.model.bind('destroy', this.remove, this);
    },

		render: function() {
      return this;
    },

		show: function() {
			setRgbaComponentsDecimalInputFromRgbaDecimalComponents(this.model.attributes.components);
			updateFromRgbaComponentsDecimal(null);
		}
	});
	
	var AppView = Backbone.View.extend({
		
		el: $("#colors-app"),
		
		events: {
			"click #save-color": 		"saveColor",
			"click #empty-drawer": 	"clearColors"
		},
		
		initialize: function() {
			Colors.bind('add', this.addOne, this);
			Colors.bind('reset', this.addAll, this);
			Colors.bind('all', this.render, this);
			Colors.fetch();
		},
		
		render: function() {
		},
		
		addOne: function(color) {
			var view = new ColorView({model: color});
			var el = view.render().el;
			this.$("#colors-drawer").append(el);
			$(el).css('background-color', rgbaDecimalComponentsToCssRgbaRepresentation(color.attributes.components));
		},
		
		addAll: function() {
			Colors.each(this.addOne);
		},
		
		saveColor: function() {
			Colors.create({components: getRgbaComponentsDecimal()});
		},
		
		clearColors: function() {
			$(Colors.models).each(function(color) {
				// Using jQuery's iteration here insteaf of Backbone's/Underscore
				// (Colors.each(...)), otherwise not all models get removed (don't
				// know why).
				this.clear();
			});
		}
		
	});
	
	var App = new AppView;
});