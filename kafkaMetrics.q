//need .init & library attachment  w/ lines 2 & 3 
/kfk/kfk.q
/kfk/gkfk.q

// kfk config
kfk_cfg:(!) . flip
  ((`group.id               ;`localhost 2020); 
   (`fetch.message.max.bytes;`2097152  ); / 2MB max message size
   (`log.connection.close   ;`false    ); / Err msg for idle broker
   (`auto.offset.reset      ;`beginning);
   (`statistics.interval.ms ;`10000    ));
kfk_cfg[`metadata.broker.list]:`$"kafka.dev"; 

//METRICS - MEMORY USEAGE
producer:.kfk.Producer[kfk_cfg]
// setup producer topic "memUse"
memory_topic:.kfk.Topic[producer;`memUse;()!()]
show "Publishing on topic:",string .kfk.TopicName memory_topic; 
.kfk.Pub[memory_topic;.kfk.PARTITION_UA;string .Q.w[]`used;"memory usage"];
show "Published 1 message";

// Memory usage kfk consumer
client:.kfk.Consumer[kfk_cfg];
.util.listToTable .gkfk.getTopics[client][`memUse]
.gkfk.TopicOffsets[client;`memUse]

data:()     // setup kfk consumer callback
.kfk.consumecb:{[msg]
  msg[`rdbuse]:.Q.w[]`used; //you have to provide encode/decode/or .j.j (JSON) somehwere to make msg human-readable
  data,::enlist msg;
};

.kfk.Sub[client;`memUse;enlist 0i]           // subscribe to memoryUsage 

//METRICS - Total Row Count 
producer:.kfk.Producer[kfk_cfg]
// setup producer topic "totRowCount"
rowc_topic:.kfk.Topic[producer;`totRowCount;()!()]
.kfk.Pub[rowc_topic;.kfk.PARTITION_UA;string count[];"row count"]; 

// Row Count kfk consumer
client:.kfk.Consumer[kfk_cfg];
.util.listToTable .gkfk.getTopics[client][`totRowCount]
.gkfk.TopicOffsets[client;`totRowCount]

data:()     // setup kfk consumer callback
.kfk.consumecb:{[msg]
  msg[`rowcount]:count[]
  data,::enlist msg;
};

.kfk.Sub[client;`totRowCount; enlist 0i]     // subscribe totRowCount

//METRICS - TABLE NAMES 
producer:.kfk.Producer[kfk_cfg]
// setup producer topic "tableNames"
tables_topic:.kfk.Topic[producer;`tableNames;()!()]
.kfk.Pub[tables_topic;.kfk.PARTITION_UA; string tables[];"table names"];

// Table names kfk consumer
client:.kfk.Consumer[kfk_cfg];
.util.listToTable .gkfk.getTopics[client][`tableNames]
.gkfk.TopicOffsets[client;`tableNames]

data:()     // setup kfk consumer callback
.kfk.consumecb:{[msg]
  /show msg;
  msg[`tablenames]:.Q.w[]`used;
  data,::enlist msg;
};

.kfk.Sub[client;`tableNames;enlist 0`]        // subscribe to tableNames 



