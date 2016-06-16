# WeaponLighting

This is a Unity5 project that's being used to solve a specific problem, namely: correctly lighting the weapon in a 2-camera system.

UFPS uses a dual-camera system where the world is rendered by one camera, and the weapon by another. This means the weapon always appears in front of any world geometry, no matter how close the player gets. However, it also means that shadow effects aren't applied to the weapon model. The weapon will self-shadow, but it won't receive shadows from any world geometry.

We're solving this for a system using two deferred-rendering cameras, with HDR. The initial approach here is going to be to scrape the G-buffer for shadow information from the first camera, store it as a global texture, and use it as input to a shader on the weapon camera so that lighting on the latter is essentially treated as "hard coded."
