import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Array "mo:base/Array";

actor {
  type IC = actor {
    sign_with_ecdsa : ({
      message_hash : Blob;
      derivation_path : [Blob];
      key_id : { curve : { #secp256k1 }; name : Text };
    }) -> async ({ signature : Blob });
  };

  let ic : IC = actor ("aaaaa-aa");

  public shared (msg) func sign() : async {
    #Ok : { signature : Blob };
    #Err : Text;
  } {
    let caller = Principal.toBlob(msg.caller);
    let messageBlob = Text.encodeUtf8("Hello world");
    let messageArray = Blob.toArray(messageBlob);
    let paddedMessageArray = Array.tabulate<Nat8>(
      32,
      func(i : Nat) : Nat8 {
        if (i < Array.size(messageArray)) {
          messageArray[i];
        } else {
          0;
        };
      },
    );
    let paddedMessageBlob = Blob.fromArray(paddedMessageArray);
    let byte1 : [Nat8] = [1];
    let byte2 : [Nat8] = [2];
    let firstInteger = Blob.fromArray(byte1);
    let secondInteger = Blob.fromArray(byte2);
    try {
      Cycles.add(10_000_000_000);
      let result = await ic.sign_with_ecdsa({
        message_hash = paddedMessageBlob;
        derivation_path = [caller, firstInteger, secondInteger];
        key_id = { curve = #secp256k1; name = "dfx_test_key" };
      });
      #Ok(result);
    } catch (err) {
      #Err(Error.message(err));
    };
  };
};
