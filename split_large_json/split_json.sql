create or replace function StripInnerArray(Fname varchar, Node varchar)                           
returns table(root variant, node variant)                                                             
language java                   
imports = ('@~/staged/json-simple-1.1.1.jar') -- Update this line to point to the location of the simple file
handler='StripInnerArray'                                                 
target_path='@~/staged/StripInnerArray.jar'                                                                
as                                                                  
$$  
    import java.io.BufferedReader;
    import java.io.InputStream;
    import java.io.IOException;
    import java.io.InputStreamReader;
    import java.nio.charset.StandardCharsets;
    import java.util.ArrayList;
    import java.util.Iterator;
    import java.util.List;
    import java.util.stream.Stream;

    import org.json.simple.*;
    import org.json.simple.parser.JSONParser;

     class StripInnerArray {
       class OutputRow {                                      
         public String root;
         public String node;
          public OutputRow(String x, String y) {
            this.root = (String) x;
            this.node = (String) y;
          }
       }                       
        public static Class getOutputClass() {
            return OutputRow.class;
        }
        public Stream<OutputRow> process(InputStream stream, String Node) throws Exception {
            BufferedReader jsonBuffer = new BufferedReader( new InputStreamReader(stream, StandardCharsets.UTF_8));

            StringBuilder contentBuilder = new StringBuilder();
            jsonBuffer.lines().forEach(s -> contentBuilder.append(s).append("\n"));
            stream.close();

            JSONParser parser = new JSONParser();
            JSONObject jsonObject = (JSONObject) parser.parse(contentBuilder.toString());

            List<JSONObject> objs = new ArrayList<JSONObject>();

            JSONObject node = (JSONObject) jsonObject.get(Node);
            Iterator<String> x = node.keySet().iterator();

            while (x.hasNext()) {
                String key = (String) x.next();
                objs.add((JSONObject) node.get(key));
            }

            jsonObject.remove(Node);

            return objs.stream().map(s -> new OutputRow(jsonObject.toString(), s.toString().replace("\\/", "/")));
        }
    }
$$;