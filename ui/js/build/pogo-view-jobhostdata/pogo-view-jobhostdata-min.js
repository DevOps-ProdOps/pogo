YUI.add("pogo-view-jobhostdata",function(a){a.namespace("Pogo.View").JobHostData=new a.Base.create("pogo-view-jobhostdata",a.View,[],{initializer:function(){var b=this.get("modelList");b.after("load",this.render,this);b.after("destroy",this.destroy,this);},template:'<h2>{jobid}\'s Hosts</h2><div class="hostdata"></div>',render:function(){var d,e,b=this.get("container"),c=this.get("modelList");b.setContent(a.Lang.sub(this.template,{jobid:this.get("jobid")}));e=b.one(".hostdata");d=new a.DataTable({columns:[{label:"Host",key:"host",nodeFormatter:a.Pogo.Formatters.hostFormatter},{label:"State",key:"state",width:"100px"},{label:"Time Started",key:"start_time",formatter:function(g){var f=a.Pogo.Formatters.timeFormatter(g);f+=" (+"+Math.floor(g.data.start_time-g.data.job_start)+"s)";return f;},width:"195px"},{label:"Duration",key:"duration",formatter:function(f){return f.value+"s";},width:"75px"},{label:"Timeline",key:"duration",nodeFormatter:function(h){var f=Math.floor(h.value/h.data.job_duration*100),g=Math.floor((h.data.start_time-h.data.job_start)/h.data.job_duration*100);h.cell.setContent(a.Node.create(a.Lang.sub('<span class="spacer" style="width: {per_start}%">{per_start}</span><span class="duration {status}" style="width: {per}%">{per}</span>',{per_start:g,per:f,status:h.data.state})));return false;},width:"250px"}],data:c});d.render(e);return this;}},{ATTRS:{jobid:{value:""}}});},"@VERSION@",{requires:["base","view"]});