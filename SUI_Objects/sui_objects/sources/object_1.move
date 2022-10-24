module sui_objects::object_1 {
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
      let color_object = new(red, green, blue, ctx);

      // To obtain the current transaction sender's address:
      // sui::tx_context::sender(ctx)
      
      transfer::transfer(color_object, sui::tx_context::sender(ctx))
  }

  public fun get_color(self: &ColorObject): (u8, u8, u8) {
      (self.red, self.green, self.blue)
  }
}

// Tests
#[test_only]
module sui_objects::object_1_test{
  use sui::test_scenario;
  use sui_objects::object_1::{Self, ColorObject};
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
            object_1::create(255, 0, 255, ctx);
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
            let (red, green, blue) = object_1::get_color(&object);
            assert!(red == 255 && green == 0 && blue == 255, 0);
            test_scenario::return_to_sender(scenario, object);
        };
        test_scenario::end(scenario_val);
    }

  //  #[test]
  //   fun test_create() {
  //       let owner = @0x1;
  //       // Create a ColorObject and transfer it to @owner, which is a test address
  //       let scenario_val = test_scenario::begin(owner);
  //       let scenario = &mut scenario_val;

  //       // Why is scope needed here?
  //       // Because the scenario is a mutable reference, we need to create a scope

  //       {
  //         // Create a ColorObject and transfer it to @owner.
  //         let ctx = test_scenario::ctx(scenario);
  //         object_1::create(255, 0, 255, ctx);
  //       };

  //       let not_owner = @0x2;
  //       // Check that not_owner does not own the just-created ColorObject.
  //       test_scenario::next_tx(scenario, &not_owner);
  //       {
  //           // address @0x1 should own the object.
  //           assert!(!test_scenario::can_take_owned<ColorObject>(scenario), 0);
  //       };
  //   }


    //     { // Transfers the object to the test address
    //         let ctx = tx_context::new(scenario);
    //         let color_object = ColorObject::new(0, 0, 0, &mut ctx);
    //         transfer::transfer(color_object, owner);
    //     }
    //     {
    //         let ctx = test_scenario::ctx(scenario);
    //         color_object::create(255, 0, 255, ctx);
    //     };
    //     // Check that @not_owner does not own the just-created ColorObject.
    //     let not_owner = @0x2;
    //     test_scenario::next_tx(scenario, not_owner);
    //     {
    //         assert!(!test_scenario::has_most_recent_for_sender<ColorObject>(scenario), 0);
    //     };
    //     // Check that @owner indeed owns the just-created ColorObject.
    //     // Also checks the value fields of the object.
    //     test_scenario::next_tx(scenario, owner);
    //     {
    //         let object = test_scenario::take_from_sender<ColorObject>(scenario);
    //         let (red, green, blue) = color_object::get_color(&object);
    //         assert!(red == 255 && green == 0 && blue == 255, 0);
    //         test_scenario::return_to_sender(scenario, object);
    //     };
    //     test_scenario::end(scenario_val);
    // }


}

