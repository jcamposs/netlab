function switchValueInHidden(hidden_id, is_checked, num){
	var value = $(hidden_id).val();

        if (is_checked){
          if (value){
            if(value.indexOf("_" + num + "_") == -1)
	      value += ",_" + num + "_";
	  }else
	    value = "_" + num + "_";
        }else{
	  if (value){
	    if (value.indexOf(",_" + num + "_") > -1){
	      value = value.replace(",_" + num + "_", "");
	    }else if (value.indexOf("_" + num + "_,") > -1){
	      value = value.replace("_" + num + "_,", "");
	    }else if (value.indexOf("_" + num + "_") > -1){
	      value = value.replace("_" + num + "_", "");
	    }
          }
        }
	$(hidden_id).val(value);

}

function switchEditor(checkbox, num){
        var is_checked = $('#'+checkbox.id).is(":checked");
        switchValueInHidden('#workspace_share_ids', is_checked, num);
        switchValueInHidden('#workspace_unshare_ids', !is_checked, num);
}
