import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';

export default function Conversations() {
  return (
    <Screen title="Conversations">
      <StateView
        variant="empty"
        title="Bientôt disponible"
        message="La messagerie n’est pas encore branchée."
      />
    </Screen>
  );
}
