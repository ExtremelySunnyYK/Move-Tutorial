module sui_objects::object_2 {
  // object creates an alias to the object module, which allows us call
  // functions in the module, such as the `new` function, without fully
  // qualifying, e.g. `sui::object::new`.
  use sui::object::{Self, UID};
  // tx_context::TxContext creates an alias to the the TxContext struct in tx_context module.
  use sui::tx_context::TxContext;
  use sui::transfer;

    struct ColorObject has key {
        id: UID,
        red: u8,
        green: u8,
        blue: u8,
    }

  fun new(red: u8, green: u8, blue: u8, ctx: &mut TxContext): ColorObject {
      ColorObject {
          id: object::new(ctx),
          red,
          green,
          blue,
      }
  }

  // This is an entry function that can be called directly by a Transaction.
  public entry fun create(red: u8, green: u8, blue: u8, ctx: &mut TxContext) {
      let object_2 = new(red, green, blue, ctx);

      // To obtain the current transaction sender's address:
      // sui::tx_context::sender(ctx)
      
      transfer::transfer(object_2, sui::tx_context::sender(ctx))
  }

  public fun get_color(self: &ColorObject): (u8, u8, u8) {
      (self.red, self.green, self.blue)
  }

    /// Copies the values of `from_object` into `into_object`.
    public entry fun copy_into(from_object: &ColorObject, into_object: &mut ColorObject) {
        into_object.red = from_object.red;
        into_object.green = from_object.green;
        into_object.blue = from_object.blue;
    }

    // Deletes the objrect
    public entry fun delete(object: ColorObject) {
        let ColorObject { id, red: _, green: _, blue: _ } = object;
        object::delete(id);
    }

    public entry fun transfer(object: ColorObject, recipient: address) {
    transfer::transfer(object, recipient)
    }
}

// Tests
#[test_only]
module sui_objects::object_2_test{
  use sui::test_scenario;
  use sui_objects::object_2::{Self, ColorObject};
  use sui::object;
  use sui::transfer;
  use sui::tx_context;

    #[test]
    fun test_create() {
        let owner = @0x1;
        // Create a ColorObject and transfer it to @owner.
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            object_2::create(255, 0, 255, ctx);
        };
        // Check that @not_owner does not own the just-created ColorObject.
        let not_owner = @0x2;
        test_scenario::next_tx(scenario, not_owner);
        {
            assert!(!test_scenario::has_most_recent_for_sender<ColorObject>(scenario), 0);
        };
        // Check that @owner indeed owns the just-created ColorObject.
        // Also checks the value fields of the object.
        test_scenario::next_tx(scenario, owner);
        {
            let object = test_scenario::take_from_sender<ColorObject>(scenario);
            let (red, green, blue) = object_2::get_color(&object);
            assert!(red == 255 && green == 0 && blue == 255, 0);
            test_scenario::return_to_sender(scenario, object);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_copy_into() {
        let owner = @0x1;
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        // Create two ColorObjects owned by `owner`, and obtain their IDs.
        let (id1, id2) = {
            let ctx = test_scenario::ctx(scenario);
            object_2::create(255, 255, 255, ctx);
            let id1 =
                object::id_from_address(tx_context::last_created_object_id(ctx));
            object_2::create(0, 0, 0, ctx);
            let id2 =
                object::id_from_address(tx_context::last_created_object_id(ctx));
            (id1, id2)
        };


        test_scenario::next_tx(scenario, owner);
        {
            let obj1 = test_scenario::take_from_sender_by_id<ColorObject>(scenario, id1);
            let obj2 = test_scenario::take_from_sender_by_id<ColorObject>(scenario, id2);
            let (red, green, blue) = object_2::get_color(&obj1);
            assert!(red == 255 && green == 255 && blue == 255, 0);

            object_2::copy_into(&obj2, &mut obj1);
            test_scenario::return_to_sender(scenario, obj1);
            test_scenario::return_to_sender(scenario, obj2);
        };


        test_scenario::next_tx(scenario, owner);
        {
            let obj1 = test_scenario::take_from_sender_by_id<ColorObject>(scenario, id1);
            let (red, green, blue) = object_2::get_color(&obj1);
            assert!(red == 0 && green == 0 && blue == 0, 0);
            test_scenario::return_to_sender(scenario, obj1);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_delete() {
        let owner = @0x1;
        // Create a ColorObject and transfer it to @owner.
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            object_2::create(255, 0, 255, ctx);
        };
        // Delete the ColorObject we just created.
        test_scenario::next_tx(scenario, owner);
        {
            let object = test_scenario::take_from_sender<ColorObject>(scenario);
            object_2::delete(object);
        };
        // Verify that the object was indeed deleted.
        test_scenario::next_tx(scenario, owner);
        {
            assert!(!test_scenario::has_most_recent_for_sender<ColorObject>(scenario), 0);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_transfer() {
        let owner = @0x1;
        // Create a ColorObject and transfer it to @owner.
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            object_2::create(255, 0, 255, ctx);
        };
        // Transfer the object to recipient.
        let recipient = @0x2;
        test_scenario::next_tx(scenario, owner);
        {
            let object = test_scenario::take_from_sender<ColorObject>(scenario);
            transfer::transfer(object, recipient);
        };
        // Check that owner no longer owns the object.
        test_scenario::next_tx(scenario, owner);
        {
            assert!(!test_scenario::has_most_recent_for_sender<ColorObject>(scenario), 0);
        };
        // Check that recipient now owns the object.
        test_scenario::next_tx(scenario, recipient);
        {
            assert!(test_scenario::has_most_recent_for_sender<ColorObject>(scenario), 0);
        };
        test_scenario::end(scenario_val);
    }


}

