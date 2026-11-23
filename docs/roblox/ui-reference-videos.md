# Roblox UI Video References

Reviewed November 22, 2026. Times are approximate positions in the original videos. The observations describe visible states. The original posts provide the footage.

- [ChetanUI/UX, November 12, 2026](https://x.com/Chetan_Ui/status/2120905519565054131)
- [ChetanUI/UX, November 15, 2026](https://x.com/Chetan_Ui/status/2121901063787999255)

| Source and time | Observed state | Design pattern to adapt |
| --- | --- | --- |
| Nov 12, 0:05 | Lucky Blocks shows a gold title strip, a small close button, and three equal-width cards. Each card repeats the same order of title, large cube, benefit, and bright bottom action. | Use one card template and put decision information in the same position across options. |
| Nov 12, 0:14 and 0:19 | The shop recedes. A large colored cube, short result label, radial streaks, and confetti fill the center. The later reward changes color while keeping the composition. | Build one result component that swaps accent and art while keeping the message and focal point stable. |
| Nov 12, 0:24 and 0:37 | The gold cube has a waiting label. The later rainbow result has a continuation cue. | Give waiting and completed states distinct messaging. Make the next action clear once ready. |
| Nov 15, 0:06, 0:14, and 0:19 | A saucer and spotlight sit above an enlarged item against a darkened shop. The focal object changes from a character to a trophy and then a heart across these sampled moments. | Reuse one sequence for several items and give each focal object a readable silhouette. |
| Nov 15, 0:36 and 0:48 | Potion activation centers a bottle with a short status label. Later, the shop is readable again, with a large featured card above two smaller game-pass cards. | Size cards by priority. Put confirmations in a temporary layer and preserve the player's browsing state. |

## Adapt to a game screen

- **Shop or Locker.** Give the selected item the largest image and keep the primary action in a predictable position. Use a firm outer silhouette, a dark boundary where it helps separation, and a restrained edge highlight where it helps controls read as solid. Shorten labels or use less ornamentation on smaller tiles.
- **Earned reward or match result.** Center the game's own icon and a short outcome line. Briefly dim the surroundings, then bring in the next action. A spotlight, scale change, or color accent can serve the same visual purpose.
- **Time-sensitive duel HUD.** Keep the topic, timer, input, and bomb readable during turns. Reserve the full-screen reveal for an intentional beat such as the match result. Check the smallest supported phone size first.
- **Reduced motion.** Preserve the same message and action with static emphasis. Verify return to the prior panel, input focus, and touch behavior.

Use the target game's palette, icons, copy, and reward rules.
