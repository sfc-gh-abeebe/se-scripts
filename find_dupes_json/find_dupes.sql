create or replace function detect_dups(v variant)
returns string
language python
runtime_version = '3.8'
handler = 'detect_dups'
as
$$
import json
import collections

def validate_data(list_of_pairs):
    key_count = collections.Counter(k for k,v in list_of_pairs)
    duplicate_keys = ', '.join(k for k,v in key_count.items() if v>1)

    if len(duplicate_keys) != 0:
        return 'Duplicate key(s) found: {}'.format(duplicate_keys)
    else:
        return dict(list_of_pairs)
        
def detect_dups(v):
    obj = json.loads(v, object_pairs_hook=validate_data)
    return obj
$$;