using Gtk;
using Gee;

public class BeatBox.SmartPlaylistEditor : Window {
	SmartPlaylist _sp;
	
	VBox content;
	HBox padding;
	
	private  Label nameLabel;
	private Label rulesLabel;
	private Label optionsLabel;
	
	ElementaryWidgets.ElementaryEntry _name;
	ComboBox comboMatch;
	VBox vertQueries;
	Gee.ArrayList<SmartPlaylistEditorQuery> spQueries;
	Button addButton;
	CheckButton limitSongs;
	SpinButton songLimit;
	Button save;
	
	public signal void playlist_saved(SmartPlaylist sp);
	
	public SmartPlaylistEditor(SmartPlaylist sp) {
		this.title = "Smart Playlist Editor";
		this.window_position = WindowPosition.CENTER;
		
		_sp = sp;
		
		content = new VBox(false, 10);
		padding = new HBox(false, 10);
		
		/* start out by creating all category labels */
		nameLabel = new Label("Name of Playlist");
		rulesLabel = new Label("Rules");
		optionsLabel = new Label("Options");
		
		/* make them look good */
		nameLabel.xalign = 0.0f;
		rulesLabel.xalign = 0.0f;
		optionsLabel.xalign = 0.0f;
		nameLabel.set_markup("<b>Name of Playlist</b>");
		rulesLabel.set_markup("<b>Rules</b>");
		optionsLabel.set_markup("<b>Options</b>");
		
		/* add the name entry */
		_name = new ElementaryWidgets.ElementaryEntry("Playlist Title");
		if(_sp.name != "")
			_name.set_text(_sp.name);
		
		/* create match checkbox/combo combination */
		HBox matchBox = new HBox(false, 2);
		Label tMatch = new Label("Match");
		comboMatch = new ComboBox.text();
		comboMatch.insert_text(0, "any");
		comboMatch.insert_text(1, "all");
		Label tOfTheFollowing = new Label("of the following:");
		
		matchBox.pack_start(tMatch, false, false, 0);
		matchBox.pack_start(comboMatch, false, false, 0);
		matchBox.pack_start(tOfTheFollowing, false, false, 0);
		
		if(_sp.conditional == "any")
			comboMatch.set_active(0);
		else
			comboMatch.set_active(1);
		
		/* create rule list */
		spQueries = new Gee.ArrayList<SmartPlaylistEditorQuery>();
		vertQueries = new VBox(true, 2);
		foreach(SmartQuery q in _sp.queries()) {
			SmartPlaylistEditorQuery speq = new SmartPlaylistEditorQuery(q);
			
			vertQueries.pack_start(speq._box, false, true, 1);
			spQueries.add(speq);
		}
		
		if(_sp.queries().size == 0) {
			addRow();
		}
		
		addButton = new Button.with_label("Add");
		vertQueries.pack_end(addButton, false, true, 1);
		addButton.clicked.connect(addButtonClick);
		
		/* create extra option: limiter */
		limitSongs = new CheckButton.with_label("Limit to");
		songLimit = new SpinButton.with_range(0, 500, 10);
		Label limiterLabel = new Label("songs");
		
		HBox limiterBox = new HBox(false, 2);
		limiterBox.pack_start(limitSongs, false, false, 0);
		limiterBox.pack_start(songLimit, false, false, 0);
		limiterBox.pack_start(limiterLabel, false, false, 0);
		
		/* add the Done button on bottom */
		HButtonBox bottomButtons = new HButtonBox();
		save = new Button.with_label("Done");
		bottomButtons.set_layout(ButtonBoxStyle.END);
		bottomButtons.pack_end(save, false, false, 0);
		
		/* put it all together */
		content.pack_start(wrap_alignment(nameLabel, 10, 0, 0, 0), false, true, 0);
		content.pack_start(wrap_alignment(_name, 0, 10, 0, 10), false, true, 0);
		content.pack_start(rulesLabel, false, true, 0);
		content.pack_start(wrap_alignment(matchBox, 0, 10, 0, 10) , false, true, 0);
		content.pack_start(wrap_alignment(vertQueries, 0, 10, 0, 10), false, true, 0);
		content.pack_start(optionsLabel, false, true, 0);
		content.pack_start(wrap_alignment(limiterBox, 0, 10, 0, 10), false, true, 0);
		content.pack_start(bottomButtons, false, false, 10);
		
		padding.pack_start(content, true, true, 10);
		
		add(padding);
		show_all();
		
		save.clicked.connect(saveClick);
	}
	
	public static Gtk.Alignment wrap_alignment (Gtk.Widget widget, int top, int right, int bottom, int left) {
		var alignment = new Gtk.Alignment(0.0f, 0.0f, 1.0f, 1.0f);
		alignment.top_padding = top;
		alignment.right_padding = right;
		alignment.bottom_padding = bottom;
		alignment.left_padding = left;
		
		alignment.add(widget);
		return alignment;
	}
	
	public void addRow() {
		SmartPlaylistEditorQuery speq = new SmartPlaylistEditorQuery(new SmartQuery());
		
		vertQueries.pack_start(speq._box, false, true, 1);
		spQueries.add(speq);
		
	}
	
	public virtual void addButtonClick() {
		addRow();
	}
	
	public virtual void saveClick() {
		_sp.clearQueries();
		foreach(SmartPlaylistEditorQuery speq in spQueries) {
			if(speq._box.visible)
				_sp.addQuery(speq.getQuery());
		}
		
		_sp.name = _name.text;
		_sp.conditional = comboMatch.get_active_text();
		
		playlist_saved(_sp);
		
		this.destroy();
	}
}

public class BeatBox.SmartPlaylistEditorQuery : GLib.Object {
	public HBox _box;
	private ComboBox _field;
	private ComboBox _comparator;
	private Entry _value;
	private Button _remove;
	
	public HashMap<string, int> fields;
	public HashMap<string, int> comparators;
	
	public signal void removed();
	
	public SmartPlaylistEditorQuery(SmartQuery q) {
		fields = new HashMap<string, int>();
		comparators = new HashMap<string, int>();
		
		fields.set("Album", 0);
		fields.set("Artist", 1);
		fields.set("Bitrate", 2);
		fields.set("Comment", 3);
		fields.set("Date Added", 4);
		fields.set("Genre", 5);
		fields.set("Last Played", 6);
		fields.set("Length", 7);
		fields.set("Playcount", 8);
		fields.set("Rating", 9);
		fields.set("Title", 10);
		fields.set("Year", 11);
		
		comparators.set("is", 0);
		comparators.set("contains", 1);
		comparators.set("does not contain", 2);
		
		_box = new HBox(false, 2);
		_field = new ComboBox.text();
		_comparator = new ComboBox.text();
		_value = new Entry();
		_remove = new Button.with_label("Remove");
		
		_field.append_text("Album");
		_field.append_text("Artist");
		_field.append_text("Bitrate");
		_field.append_text("Comment");
		_field.append_text("Date Added");
		_field.append_text("Genre");
		_field.append_text("Last Played");
		_field.append_text("Length");
		_field.append_text("Playcount");
		_field.append_text("Rating");
		_field.append_text("Title");
		_field.append_text("Year");
		
		_comparator.append_text("is");
		_comparator.append_text("contains");
		_comparator.append_text("does not contain");
		
		_field.set_active(fields.get(q.field));
		_comparator.set_active(comparators.get(q.comparator));
		_value.text = q.value;
		
		_box.pack_start(_field, false, true, 0);
		_box.pack_start(_comparator, false ,true, 1);
		_box.pack_start(_value, false, true, 1);
		_box.pack_start(_remove, false, true, 0);
		
		_box.show_all();
		
		_remove.clicked.connect(removeClicked);
	}
	
	public SmartQuery getQuery() {
		SmartQuery rv = new SmartQuery();
		
		rv.field = _field.get_active_text();
		rv.comparator = _comparator.get_active_text();
		rv.value = _value.text;
		
		
		return rv;
	}
	
	public virtual void removeClicked() {
		removed();
		this._box.hide();
	}
}
