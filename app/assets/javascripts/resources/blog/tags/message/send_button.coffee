Blog.SendMessageButton = Ember.View.extend
	template: Ember.Handlebars.compile("Send Message")
	tagName: 'button'
	classNames: ['btn', 'btn-success','btn-large']
	attributeBindings: ['disabled']
	disabled: true
	